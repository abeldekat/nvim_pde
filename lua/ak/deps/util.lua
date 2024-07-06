local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  register("dstein64/vim-startuptime")
  Util.defer.on_keys(function()
    now(function()
      add("dstein64/vim-startuptime")
      require("ak.config.util.startuptime")
    end)
  end, "<leader>os", "StartupTime")

  -- TODO: newest commits for vim-slime: terminal not found
  register({ source = "jpalardy/vim-slime", checkout = "a532203bcd7af7f5e571c07b60bba7287076dc19" })
  Util.defer.on_keys(function()
    now(function()
      add({ source = "jpalardy/vim-slime" })
      require("ak.config.util.slime")
    end)
  end, "<leader>or", "Repl")

  -- Documentation generator
  register("danymat/neogen")
  Util.defer.on_keys(function()
    now(function()
      add("danymat/neogen")
      require("ak.config.util.neogen")
    end)
  end, "<leader>oN", "Neogen")

  Util.defer.on_keys(function()
    now(function() require("ak.config.util.mini_doc") end)
  end, "<leader>oD", "Mini doc")
end)
