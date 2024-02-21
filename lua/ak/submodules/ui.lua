--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.submodules.later
local later_only = Util.submodules.later_only
local dashboard_now = Util.opened_without_arguments()

vim.o.statusline = " " -- wait till statusline plugin is loaded
if dashboard_now then
  add("dashboard-nvim")
  require("ak.config.ui.dashboard")
end

later(function()
  require("ak.config.ui.mini_statusline")

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

  add("indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")
end)

later_only(function() Util.submodules.source_after("indent-blankline.nvim", "ui") end)
