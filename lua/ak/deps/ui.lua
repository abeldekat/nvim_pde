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
        name = "1. Clean",
        section = "Deps",
      },
      { -- the s query is not working with leap
        action = "DepsSnapSave",
        name = "2. SnapSave",
        section = "Deps",
      },
      {
        action = "DepsUpdate",
        name = "3. Update",
        section = "Deps",
      },
    }, function() return "  Press space for the menu" end)
  end
end)

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │       Mini.notify is used in ak.deps.start              │
  --          ╰─────────────────────────────────────────────────────────╯
  local on_update = function() vim.wo.statusline = "%!v:lua.MiniStatusline.active()" end
  add({ source = "abeldekat/harpoonline", checkout = "stable" })
  add({ source = "abeldekat/grappleline", checkout = "stable" })
  -- require("ak.config.ui.harpoonline").setup(on_update)
  require("ak.config.ui.grappleline").setup(on_update)
  require("ak.config.ui.mini_statusline")

  add("lukas-reineke/indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  -- telescope ui select replaces stevearc/dressing.nvim
end)
