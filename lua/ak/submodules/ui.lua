--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later
local dashboard_now = Util.opened_without_arguments()

local function dashboard()
  add("dashboard-nvim")
  require("ak.config.intro")
end

if not Util.ui.use_mini_statusline then
  require("ak.config.lualine_init")
else
  add("mini.statusline")
  require("ak.config.mini_statusline")
end

if dashboard_now then
  dashboard()
end

later(function()
  if not Util.ui.use_mini_statusline then
    add("lualine.nvim")
    require("ak.config.lualine")
  end

  local function dressing()
    add("dressing.nvim")
  end
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
  require("ak.config.indent_blankline")
end)
