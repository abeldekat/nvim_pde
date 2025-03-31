-- Language components are configurated in: treesitter, lintiner, formatting
-- mason, diagnostics, lsp, test and debug, language specific plugins
-- find symbols under <leader>f...
-- Minifiles, rename files...

local Util = require("ak.util")
local Picker = Util.pick
local methods = vim.lsp.protocol.Methods

local inlay_hints = { "lua" } -- automatically for these filetypes...

local add_keymaps = function(client, buffer) -- see :h lsp-quickstart
  local function keymap(l, r, desc, mode)
    mode = mode or "n"
    vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
  end

  -- Start override native mappings:
  -- See lsp-defaults, gr, go refactor...
  keymap("grr", Picker.lsp_references, "References")
  keymap("gri", Picker.lsp_implementations, "Goto implementation")
  -- gra: code action, grn: rename, <c-s>: signature help -- in insert mode --
  -- gO: buf document symbol, K: vim.lsp.buf.hover() unless customized `keywordprog` exists
  -- End override native mappings

  if client:supports_method(methods.textDocument_signatureHelp) then
    keymap("gK", function() vim.lsp.buf.signature_help() end, "Signature help")
  end
  if client:supports_method(methods.textDocument_definition) then
    keymap("gd", Picker.lsp_definitions, "Goto definition")
  end
  -- Use goto definition instead?
  if client:supports_method(methods.textDocument_declaration) then
    keymap("gD", vim.lsp.buf.declaration, "Goto declaration")
  end

  if client:supports_method(methods.textDocument_codeAction) then
    local function source_action() vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } }) end
    keymap("<leader>cA", source_action, "Source action")
  end
  if client:supports_method(methods.textDocument_codeLens) then
    keymap("<leader>cc", vim.lsp.codelens.run, "Run Codelens", { "n", "v" })
    keymap("<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
  end
  keymap("<leader>cl", "<cmd>checkhealth vim.lsp<cr>", "Lsp info")
  -- Used to be gy. Mappings gy and gY are used to copy to clipboard
  if client:supports_method(methods.textDocument_typeDefinition) then
    keymap("<leader>cy", Picker.lsp_type_definitions, "Goto type definition")
  end
end

local add_completion = function(buffer)
  if Util.completion == "mini" then vim.bo[buffer].omnifunc = "v:lua.MiniCompletion.completefunc_lsp" end
end

local add_inlay_hints = function(client, buffer)
  if not client:supports_method(methods.textDocument_inlayHint) then return end
  if not (vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "") then return end

  if vim.tbl_contains(inlay_hints, vim.bo[buffer].filetype) then
    Util.toggle.inlay_hints(buffer, true) --
  end
end

local on_attach = function(client, buffer)
  add_keymaps(client, buffer)
  add_completion(buffer)
  add_inlay_hints(client, buffer)
end

local with_lspconfig = function(names, capabilities)
  for _, name in ipairs(names) do
    local opts = require("ak.config.lang.with_lspconfig." .. name)
    opts.capabilities = vim.tbl_deep_extend("force", {}, capabilities, opts.capabilities or {})
    require("lspconfig")[name].setup(opts)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ak_lsp", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    on_attach(client, args.buf)
  end,
})

vim.lsp.handlers["client/registerCapability"] = (function(overridden)
  return function(err, res, ctx) -- dynamic registration
    local result = overridden(err, res, ctx)
    local client = vim.lsp.get_client_by_id(ctx.client_id)
    if not client then return end

    add_keymaps(client, vim.api.nvim_get_current_buf())
    return result
  end
end)(vim.lsp.handlers["client/registerCapability"])

local capabilities = vim.lsp.protocol.make_client_capabilities()
if Util.completion == "blink" then
  capabilities = vim.tbl_deep_extend("force", {}, require("blink.cmp").get_lsp_capabilities(capabilities))
elseif Util.completion == "cmp" then
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  capabilities = vim.tbl_deep_extend("force", capabilities, has_cmp and cmp_nvim_lsp.default_capabilities() or {})
end

-- Servers with "simple" configuration:
vim.lsp.config("*", { capabilities = capabilities, root_markers = { ".git" } }) -- all clients
vim.lsp.enable({
  "bash-language-server",
  "json-lsp",
  "lua-language-server",
  "marksman",
  "ruff",
  "taplo",
  "yaml-language-server",
})

-- Servers with more complicated configuration, using nvim-lspconfig
-- ltex = {}, -- grammar/spelling checker, needs jre(installed jre-openjdk-headless)
with_lspconfig({ "basedpyright", "gopls", "texlab", "zls" }, capabilities)

-- Rust with rust-analyzer, not installed by mason, setup is done in rustacenvim plugin
-- including capabilities
local rust_opts = require("ak.config.lang.with_lspconfig.rust-analyzer")
vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, rust_opts or {})
