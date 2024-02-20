local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

later(function()
  add("conform.nvim")
  require("ak.config.lang.formatting")
end)
