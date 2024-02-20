local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add("stevearc/conform.nvim")
  require("ak.config.lang.formatting")
end)
