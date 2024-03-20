local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  local spec = {
    source = "mfussenegger/nvim-dap",
    depends = {
      "jay-babu/mason-nvim-dap.nvim",
      "nvim-neotest/nvim-nio", -- dependency for dap ui
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
      "jbyuki/one-small-step-for-vimkind", -- lua
    },
  }
  local function load()
    add(spec)
    require("ak.config.lang.debugging")
  end
  register(spec)
  Util.defer.on_keys(function() now(load) end, "<leader>dL", "Load dap")
end)
