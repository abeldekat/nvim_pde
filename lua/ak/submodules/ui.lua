--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later
local later_only = Util.defer.later_only
local dashboard_now = Util.opened_without_arguments()

vim.o.statusline = " " -- wait till statusline plugin is loaded
if dashboard_now then
  add("dashboard-nvim")
  require("ak.config.ui.dashboard")
end

later(function()
  add("mini.statusline")
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

later_only(function()
  ---@param path_after_opt table
  local function source_after_plugin(path_after_opt)
    local to_source = Util.submodules.file_in_pack_path("ui", path_after_opt)
    vim.cmd.source(to_source)
  end
  source_after_plugin({ "indent-blankline.nvim", "after", "plugin", "commands.lua" })
end)
