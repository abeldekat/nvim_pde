-- Tools used without lsp:
-- prettier, arch linux: sudo pacman -S prettier

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
  -- Using completefunc to be able to use ctrl-o to temporarily
  -- escape to normal mode. See mini discussions #1736
  if Util.completion == "mini" then vim.bo[buffer].completefunc = "v:lua.MiniCompletion.completefunc_lsp" end
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

vim.lsp.config("*", { capabilities = Util.completion == "mini" and MiniCompletion.get_lsp_capabilities() or nil })
vim.lsp.enable({
  "basedpyright",
  "bashls",
  "gopls",
  "jsonls",
  "lua_ls",
  "marksman",
  "ruff",
  "rust_analyzer",
  "taplo",
  "texlab",
  "yamlls",
})

-- TODO: Remove when PR 3666 lands. Zig is not ported yet to vim.lsp.config
local capabilities = {}
if Util.completion == "mini" then
  capabilities =
    vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), MiniCompletion.get_lsp_capabilities())
elseif Util.completion == "blink" then
  capabilities = require("blink.cmp").get_lsp_capabilities({}, true)
end
require("lspconfig").zls.setup({
  capabilities = vim.tbl_deep_extend("force", {}, capabilities),
})
