local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

later(function()
  add("nvim-treesitter")
  add("nvim-treesitter-textobjects")
  require("ak.config.treesitter")

  add("nvim-ts-autotag")
  require("ak.config.treesitter_autotag")

  add("nvim-treesitter-context")
  require("ak.config.treesitter_context")
end)
