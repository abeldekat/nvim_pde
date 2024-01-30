local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

later(function()
  Util.defer.on_keys(function()
    add("vim-startuptime")
    require("ak.config.startuptime")
  end, "<leader>ms", "StartupTime")

  Util.defer.on_keys(function()
    add("vim-slime")
    require("ak.config.repl")
  end, "<leader>mr", "Repl")

  -- Util.defer.on_events(function()
  --     add("persistence.nvim")
  --     require("ak.config.persistence")
  -- end, "BufReadPre")
end)
