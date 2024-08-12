local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  local spec_startuptime = "dstein64/vim-startuptime"
  register(spec_startuptime)
  Util.defer.on_keys(function()
    now(function()
      add(spec_startuptime)
      require("ak.config.util.startuptime")
    end)
  end, "<leader>os", "StartupTime")

  local spec_slime = { source = "jpalardy/vim-slime" }
  register(spec_slime)
  Util.defer.on_keys(function()
    now(function()
      require("ak.config.util.slime")
      add(spec_slime)
    end)
  end, "<leader>oR", "Load slime(repl)")

  -- Documentation generator
  local spec_neogen = "danymat/neogen"
  register(spec_neogen)
  Util.defer.on_keys(function()
    now(function()
      add(spec_neogen)
      require("ak.config.util.neogen")
    end)
  end, "<leader>oN", "Neogen")

  -- Util.defer.on_keys(function()
  --   now(function() require("ak.config.util.mini_doc") end)
  -- end, "<leader>oD", "Mini doc")
end)
