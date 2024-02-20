-- Also see: telescope-alternate

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
  local spec = {
    source = "nvim-neotest/neotest",
    depends = { "nvim-neotest/neotest-python" },
  }
  local function load()
    add(spec)
    require("ak.config.lang.testing")
  end

  add(spec, { bang = true }) -- register
  Util.defer.on_keys(function() now(load) end, "<leader>tL", "Load neotest")
end)
