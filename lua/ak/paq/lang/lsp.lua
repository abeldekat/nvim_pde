local Util = require("ak.util")
local M = {}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

local lsp_spec = {
  { "folke/neoconf.nvim", opt = true },
  { "folke/neodev.nvim", opt = true },
  { "williamboman/mason.nvim", build = ":MasonUpdate", opt = true },
  { "williamboman/mason-lspconfig.nvim", opt = true },
  { "neovim/nvim-lspconfig", opt = true },
  -- Only does something when required:
  { "b0o/SchemaStore.nvim" },
}

local function load_mason()
  vim.cmd.packadd("mason.nvim")
  require("ak.config.lang.mason")
end

function M.spec()
  Util.paq.on_command(function()
    load_mason()
  end, "MasonUpdate")
  Util.paq.on_command(function()
    load_mason()
  end, "Mason")
  return lsp_spec
end

function M.setup()
  Util.paq.on_events(function()
    load_mason()

    vim.cmd.packadd("neoconf.nvim")
    vim.cmd.packadd("neodev.nvim")
    vim.cmd.packadd("mason-lspconfig.nvim")
    vim.cmd.packadd("nvim-lspconfig")
    require("ak.config.lang.lspconfig")
  end, lazyfile())
end
return M