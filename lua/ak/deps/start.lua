local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require("ak.config.options")
  require("ak.config.autocmds")
  require("ak.config.keymaps")
  require("ak.config.ui.mini_notify") -- mini.nvim in pack start
  require("ak.deps.colors").colorscheme()
end)
later(function() add("nvim-lua/plenary.nvim") end)
