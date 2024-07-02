--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

vim.o.statusline = " " -- wait till statusline plugin is loaded

now(function()
  if Util.opened_without_arguments() then
    local section = "Deps"
    require("ak.config.ui.mini_starter").setup({
      section = section,
      items = {
        {
          action = "DepsUpdate",
          name = "u. update",
          section = section,
        },
        {
          action = "DepsSnapSave",
          name = "a. snapSave",
          section = section,
        },
        {
          action = "DepsClean",
          name = "c. clean",
          section = section,
        },
      },
      query_updaters = "uac",
    })
  end
end)

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │       Mini.notify is used in ak.deps.start              │
  --          ╰─────────────────────────────────────────────────────────╯
  -- add({ source = "abeldekat/harpoonline", checkout = "stable" }) -- download when needed
  require("ak.config.ui.mini_statusline")

  add("lukas-reineke/indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  -- PERF: :Startuptime is slower....
  require("ak.config.ui.mini_animate")
end)
