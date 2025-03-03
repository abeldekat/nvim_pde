local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  local spec = {
    source = "nvim-neotest/neotest",
    depends = { "nvim-neotest/nvim-nio" },
  }
  register(spec)
  local function load()
    add(spec)
    require("ak.config.lang.testing")
    vim.notify("Loaded neotest", vim.log.levels.INFO)
  end
  Util.defer.on_keys(function() now(load) end, "<leader>tL", "Load neotest")
end)
