--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

vim.o.statusline = " " -- wait till statusline plugin is loaded

now(function()
  if Util.opened_without_arguments() then -- dashboard loads on UIEnter...
    require("ak.config.ui.mini_starter").setup({
      {
        action = "DepsUpdate",
        name = "Update",
        section = "Deps",
      },
      {
        action = "DepsSnapSave",
        name = "SnapSave",
        section = "Deps",
      },
    }, function() return "Press space for the menu" end)
  end
end)

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │       Mini.notify is used in ak.submodules.start        │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.ui.mini_statusline")

  add("lukas-reineke/indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  register("stevearc/dressing.nvim")
  local function dressing() add("stevearc/dressing.nvim") end

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(...)
    dressing()
    return vim.ui.select(...)
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.input = function(...)
    dressing()
    return vim.ui.input(...)
  end
end)
