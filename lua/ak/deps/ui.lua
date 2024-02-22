--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local dashboard_now = Util.opened_without_arguments()

vim.o.statusline = " " -- wait till statusline plugin is loaded
now(function()
  if dashboard_now then
    add("nvimdev/dashboard-nvim")
    require("ak.config.ui.dashboard")
  else
    add("nvimdev/dashboard-nvim", { bang = true }) -- register
  end
end)

later(function()
  require("ak.config.ui.mini_statusline")
  -- mini.notify is used in ak.deps.start

  add("lukas-reineke/indent-blankline.nvim")
  require("ak.config.ui.indent_blankline")

  add("stevearc/dressing.nvim", { bang = true }) -- register
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
