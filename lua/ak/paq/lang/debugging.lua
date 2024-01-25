local Util = require("ak.util")

local M = {}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

local debug_spec = {
  { "rcarriga/nvim-dap-ui", opt = true },
  { "theHamsta/nvim-dap-virtual-text", opt = true },
  { "jay-babu/mason-nvim-dap.nvim", opt = true },
  { "mfussenegger/nvim-dap-python", opt = true },
  { "mfussenegger/nvim-dap", opt = true },
}

local function load_dap()
  vim.cmd.packadd("mason-nvim-dap.nvim")
  vim.cmd.packadd("nvim-dap-ui")
  vim.cmd.packadd("nvim-dap-virtual-text")
  vim.cmd.packadd("nvim-dap-python")
  vim.cmd.packadd("nvim-dap")
  require("ak.config.lang.debugging")
end

function M.spec()
  return debug_spec
end

function M.setup()
  Util.defer.on_events(function()
    Util.defer.on_keys(function()
      load_dap()
    end, "<leader>dL", "Load dap")
  end, lazyfile()) -- mason needs to be loaded
end
return M
