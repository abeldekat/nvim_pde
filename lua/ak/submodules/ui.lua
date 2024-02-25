--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later
local later_only = Util.submodules.later_only

vim.o.statusline = " " -- wait till statusline plugin is loaded

if Util.opened_without_arguments() then -- dashboard loads on UIEnter...
  add("dashboard-nvim")
  require("ak.config.ui.dashboard").setup({}, function() return { "Press space for the menu" } end)
end

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │       Mini.notify is used in ak.submodules.start        │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.ui.mini_statusline")

  add("indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  local function dressing() add("dressing.nvim") end
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

later_only(function() Util.submodules.source_after("indent-blankline.nvim", "ui") end)
