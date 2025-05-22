local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local use_mason = false

later(function()
  if use_mason then
    add("williamboman/mason.nvim")
    require("mason").setup()
  end

  add("b0o/SchemaStore.nvim")
  add("neovim/nvim-lspconfig")
  require("ak.config.lang.lsp")

  if not Util.opened_with_arguments() then return end

  -- The lsp does not attach when directly opening a file:
  local ft = vim.bo.filetype
  if ft and ft ~= "minifiles" then
    vim.api.nvim_exec_autocmds("FileType", {
      modeline = false,
      pattern = vim.bo.filetype,
    })
  end
end)
