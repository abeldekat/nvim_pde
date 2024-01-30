local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

later(function()
  add("conform.nvim")
  require("ak.config.lang.formatting")
end)
