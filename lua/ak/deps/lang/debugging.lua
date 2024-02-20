local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
  local spec = {
    source = "mfussenegger/nvim-dap",
    depends = {
      "jay-babu/mason-nvim-dap.nvim",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
  }
  local function load()
    add(spec)
    require("ak.config.lang.debugging")
  end
  add(spec, { bang = true })
  Util.defer.on_keys(function() now(load) end, "<leader>dL", "Load dap")
end)
