-- NOTE: Not used at the moment. No rust or go support...Also, consider nvim-dap-view

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  local spec = {
    source = "mfussenegger/nvim-dap",
    depends = {
      "nvim-neotest/nvim-nio", -- dependency for dap ui
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "jbyuki/one-small-step-for-vimkind", -- lua
    },
  }
  register(spec)
  local function load()
    add(spec)
    require("ak.config.lang.debugging")
    vim.notify("Loaded nvim-dap", vim.log.levels.INFO)
  end
  Util.defer.on_keys(function() now(load) end, "<leader>dL", "Load dap")
end)
