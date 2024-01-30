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

require("ak.config.lualine_init")
if dashboard_now then
  dashboard()
end

later(function()
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

  add("lualine.nvim")
  require("ak.config.lualine")
end)
