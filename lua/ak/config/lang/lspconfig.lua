--          ╭─────────────────────────────────────────────────────────╮
--          │        Language components are configurated in:         │
--          │                       treesitter                        │
--          │                         linting                         │
--          │                       formatting                        │
--          │                           lsp                           │
--          │                 lsp.langs(server opts)                  │
--          │                     test and debug                      │
--          │                language specific plugins                │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

---@class Opts
local Opts = {}
setmetatable(Opts, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ak.config.lang.opts." .. k)
    return t[k]
  end,
})

local mason_lspconfig_ensure_installed = {
  "lua_ls",
  "jsonls",
  "yamlls",
  "bashls",
  "marksman",
  "pyright",
  "ruff_lsp",
}

local function keys(_, buffer) -- client
  local function map(l, r, opts, mode)
    mode = mode or "n"
    opts["buffer"] = buffer
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  map("<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
  map("gd", "<cmd>Telescope lsp_definitions reuse_win=true<cr>", { desc = "Goto definition" })
  map("gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
  map("gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  map("gI", "<cmd>Telescope lsp_implementations reuse_win=true<cr>", { desc = "Goto implementation" })
  map("gy", "<cmd>Telescope lsp_type_definitions reuse_win=true<cr>", { desc = "Goto type definition" })
  map("K", vim.lsp.buf.hover, { desc = "Hover" })
  map("gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
  map("<c-k>", vim.lsp.buf.signature_help, { desc = "Signature help" }, "i")
  map("<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" }, { "n", "v" })
  map("<leader>cA", function()
    vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
  end, { desc = "Source action" })
  map("<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

  -- Also possible
  -- local methods = vim.lsp.protocol.Methods
  -- if client.supports_method(methods.textDocument_codeAction) then
  -- end
end

local function diagnostics()
  local opts = {
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
      -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
      -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
      -- prefix = "icons",
    },
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = require("ak.consts").icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = require("ak.consts").icons.diagnostics.Warn,
        [vim.diagnostic.severity.HINT] = require("ak.consts").icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = require("ak.consts").icons.diagnostics.Info,
      },
    },
  }

  for name, icon in pairs(require("ak.consts").icons.diagnostics) do
    name = "DiagnosticSign" .. name
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end

  -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
  -- Be aware that you also will need to properly configure your LSP server to
  -- provide the inlay hints.
  -- if opts.inlay_hints.enabled then
  --   Util.lsp.on_attach(function(client, buffer)
  --     if client.supports_method("textDocument/inlayHint") then
  --       Util.toggle.inlay_hints(buffer, true)
  --     end
  --   end)
  -- end

  if type(opts.virtual_text) == "table" and opts.virtual_text.prefix == "icons" then
    opts.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
      or function(diagnostic)
        local icons = require("ak.consts").icons.diagnostics
        for d, icon in pairs(icons) do
          if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
            return icon
          end
        end
      end
  end

  vim.diagnostic.config(vim.deepcopy(opts))
end

local function get_global_capabilities()
  local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  return vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    {} -- add any global capabilities here
  )
end

local function handler(global_capabilities)
  return function(server_name)
    -- The lsp is installed but removed from mason_lspconfig_ensure_installed
    -- Mason's handler would be activated:
    if not vim.tbl_contains(mason_lspconfig_ensure_installed, server_name) then
      return
    end

    local server_opts = Opts[server_name]["server"] or {}
    server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(global_capabilities),
    }, server_opts)

    local before_setup = Opts[server_name]["setup"]
    if before_setup and before_setup(server_name, server_opts) then
      return -- do not use lspconfig when before_setup returns true
    end

    require("lspconfig")[server_name].setup(server_opts)
  end
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Setup                          │
--          ╰─────────────────────────────────────────────────────────╯
local function setup()
  -- ── utility ───────────────────────────────────────────────────────────
  -- with neoconf.nvim, you can easily set project local Neodev settings.
  require("neoconf").setup()
  require("neodev").setup()

  -- ── keymaps ───────────────────────────────────────────────────────────
  Util.lsp.on_attach(function(client, buffer) -- keymaps
    keys(client, buffer) -- are always set regardles of capabilities
  end)

  -- ── diagnostics ───────────────────────────────────────────────────────
  diagnostics() -- TODO: diagnostics inlay_hints

  -- ── capabilities ──────────────────────────────────────────────────────
  local global_capabilities = get_global_capabilities()

  -- ── setup ─────────────────────────────────────────────────────────────
  -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
  -- if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
  --   setup(server) --> becomes: handler(global_capabilities)(server_name)
  require("mason-lspconfig").setup({ -- all handled by mason
    ensure_installed = mason_lspconfig_ensure_installed,
    handlers = { handler(global_capabilities) }, -- mason handles the lspconfig setup
  })
end
setup()
