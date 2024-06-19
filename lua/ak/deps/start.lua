local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

now(function()
  require("ak.config.options")
  require("ak.config.autocmds")

  -- Needed for a smoother installation process:
  require("ak.config.ui.mini_notify") -- mini.nvim in pack start
end)

later(function()
  require("ak.config.keymaps") -- load the keymaps first in the later phase

  require("mini.extra").setup() -- adds for example extra pickers
  add("nvim-lua/plenary.nvim") -- needed for harpoon and possibly other plugins

  -- Only used for completion when browsing other configs:
  register("folke/lazy.nvim")
  register("LazyVim/LazyVim")
end)
