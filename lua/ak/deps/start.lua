local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require("ak.config.options")
  require("ak.config.autocmds")
  require("ak.config.mini_misc") -- ie last cursor position
end)

later(function()
  require("ak.config.keymaps") -- load the keymaps first in the later phase
  require("ak.config.mini_extra")
  -- Needed for a smoother installation process:
  require("ak.config.mini_notify") -- mini.nvim in pack start

  add("nvim-lua/plenary.nvim") -- needed for harpoon and possibly other plugins
end)
