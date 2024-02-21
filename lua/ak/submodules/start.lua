local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later

add("mini.nvim")

require("ak.config.options")
require("ak.config.ui.mini_notify") -- mini.nvim in pack/start_ak/start
require("ak.submodules.colors").colorscheme()

later(function()
  require("ak.config.autocmds") -- load the autocmds first in the later phase
  require("ak.config.keymaps") -- load the keymaps first in the later phase
  add("plenary.nvim") -- needed for harpoon and possibly other plugins
end)
