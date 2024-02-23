local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require("ak.config.options")
  require("ak.config.autocmds")

  -- Needed for a smoother installation process:
  require("ak.config.ui.mini_notify") -- mini.nvim in pack start

  require("ak.deps.colors").colorscheme()
end)
later(function()
  require("ak.config.keymaps") -- load the keymaps first in the later phase
  add("nvim-lua/plenary.nvim") -- needed for harpoon and possibly other plugins
end)
