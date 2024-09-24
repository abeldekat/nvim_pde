local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  local spec = {
    source = "nvim-neotest/neotest",
    depends = { "nvim-neotest/nvim-nio" },
  }
  local function load()
    add(spec)
    require("ak.config.lang.testing")
  end

  register(spec)
  Util.defer.on_keys(function() now(load) end, "<leader>tL", "Load neotest")
end)
