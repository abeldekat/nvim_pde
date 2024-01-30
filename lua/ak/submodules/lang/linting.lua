local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

later(function()
  add("nvim-lint")
  require("ak.config.lang.linting")
end)
