local M = {}

local lsp_spec = {

  "folke/neoconf.nvim",
  "folke/neodev.nvim",
  { "williamboman/mason.nvim", build = ":MasonUpdate" },
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",
  --
  "b0o/SchemaStore.nvim", -- lazy, add when loading lspconfig?
}

function M.spec()
  return lsp_spec
end

function M.setup()
  require("ak.config.lang.mason") -- cmd
  require("ak.config.lang.lspconfig") -- event
end
return M
