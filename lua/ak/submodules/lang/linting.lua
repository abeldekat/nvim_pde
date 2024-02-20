local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

later(function()
  add("nvim-lint")
  require("ak.config.lang.linting")
end)
