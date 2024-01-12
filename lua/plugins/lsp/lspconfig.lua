--[[
Language components are configurated in:
plugins.treesitter
plugins.linting
plugins.formatting
plugins.lsp
plugins.lsp.langs(supply server opts)
TODO: test and debug
TODO: language specific plugins
--]]

local Util = require("util")

---@class Langs
local Langs = {}
setmetatable(Langs, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("plugins.lsp.langs." .. k)
    return t[k]
  end,
})

local mason_ensure_installed = {
  "markdownlint", -- linter
  "stylua", -- formatter
  "shfmt", -- formatter
  "black", -- formatter python
  "sql-formatter", -- formatter sql
  -- "debugpy", -- dap python
}
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
  local function map(mode, l, r, opts)
    opts["buffer"] = buffer
    opts["silent"] = opts.silent ~= false
    vim.keymap.set(mode, l, r, opts)
  end
  map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp info" })
  map("n", "gd", function()
    require("telescope.builtin").lsp_definitions({ reuse_win = true })
  end, { desc = "Goto definition" })
  map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
  map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
  map("n", "gI", function()
    require("telescope.builtin").lsp_implementations({ reuse_win = true })
  end, { desc = "Goto implementation" })
  map("n", "gy", function()
    require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
  end, { desc = "Goto type definition" })
  map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
  map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature help" })
  map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
  map({ "n" }, "<leader>cA", function()
    vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
  end, { desc = "Source action" })
  map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
end

local function mason_spec() -- also: automatically install non-lsp
  return {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    build = ":MasonUpdate",
    opts = {
      ensure_installed = mason_ensure_installed,
    },
    ---@param opts MasonSettings | {ensure_installed: string[]}
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          -- trigger FileType event to possibly load this newly installed LSP server
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  }
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
  }
  for name, icon in pairs(require("misc.consts").icons.diagnostics) do
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
        local icons = require("misc.consts").icons.diagnostics
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
    -- Use case:
    -- The lsp is installed, but removed from mason_lspconfig_ensure_installed
    -- As the lsp is installed, mason's handler is activated and so is the lsp.
    if not vim.tbl_contains(mason_lspconfig_ensure_installed, server_name) then
      return
    end

    local server_opts_lang = Langs[server_name]["server"] or {}
    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(global_capabilities),
    }, server_opts_lang)

    local _setup = Langs[server_name]["setup"]
    if _setup and _setup(server_name, server_opts) then
      return -- do not setup with lspconfig
    end
    require("lspconfig")[server_name].setup(server_opts)
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
    -- stylua: ignore start
    -- don't expose the Neoconf command... First load neoconf, then nvim-lspconfig
    { "folke/neoconf.nvim", config = function() require("neoconf").setup() end},
    { "folke/neodev.nvim", config = function() require("neodev").setup() end, },
      -- stylua: ignore end
      mason_spec(),
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      Util.format.register(Util.lsp.formatter()) -- formatter
      Util.lsp.on_attach(function(client, buffer) -- keymaps
        keys(client, buffer) -- are always set regardles of capabilities
      end)
      diagnostics() -- TODO: diagnostics inlay_hints

      local _global_capabilities = get_global_capabilities()
      -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
      -- if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
      --   setup(server) --> becomes: handler(_global_capabilities)(server_name)
      require("mason-lspconfig").setup({ -- all handled by mason
        ensure_installed = mason_lspconfig_ensure_installed,
        handlers = { handler(_global_capabilities) }, -- let mason handle the setup
      })
    end,
  },
  { -- yaml schema support
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },
}
