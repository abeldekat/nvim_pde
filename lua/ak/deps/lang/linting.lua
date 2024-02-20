local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add("mfussenegger/nvim-lint")
  require("ak.config.lang.linting")
end)
