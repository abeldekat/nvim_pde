--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

vim.o.statusline = " " -- wait till statusline plugin is loaded

now(function()
  if Util.opened_without_arguments() then -- dashboard loads on UIEnter...
    require("ak.config.ui.mini_starter").setup({
      {
        action = "DepsClean",
        name = "Clean",
        section = "Deps",
      },
      {
        action = "DepsSnapSave",
        name = "SnapSave",
        section = "Deps",
      },
      {
        action = "DepsUpdate",
        name = "Update",
        section = "Deps",
      },
    }, function() return "  Press space for the menu" end)
  end
end)

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │       Mini.notify is used in ak.deps.start              │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.ui.mini_statusline")

  add("lukas-reineke/indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  -- telescope ui select replaces stevearc/dressing.nvim
end)
