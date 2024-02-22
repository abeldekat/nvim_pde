local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

add("mini.nvim")

require("ak.config.options")
require("ak.submodules.colors").colorscheme()

later(function() -- the first to load in the later phase
  require("ak.config.autocmds") -- load the autocmds first in the later phase
  require("ak.config.keymaps") -- load the keymaps first in the later phase
  add("plenary.nvim") -- needed for harpoon and possibly other plugins
end)
