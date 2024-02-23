local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

add("mini.nvim")

require("ak.config.options")
require("ak.config.autocmds")

-- Needed for a smoother installation process:
require("ak.config.ui.mini_notify") -- mini.nvim in pack start

require("ak.submodules.colors").colorscheme()

later(function() -- the first to load in the later phase
  require("ak.config.keymaps") -- load the keymaps first in the later phase
  add("plenary.nvim") -- needed for harpoon and possibly other plugins
end)
