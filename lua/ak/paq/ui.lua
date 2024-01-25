--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local M = {}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

local function verylazy()
  return "UIEnter"
end

local ui_spec = {
  { "nvimdev/dashboard-nvim", opt = true },
  { "stevearc/dressing.nvim", opt = true },
  { "lukas-reineke/indent-blankline.nvim", opt = true },
  { "nvim-lualine/lualine.nvim", opt = true },
}

function M.spec()
  return ui_spec
end

function M.setup()
  require("ak.config.lualine_init")

  if Util.opened_without_arguments() then
    Util.defer.on_events(function()
      vim.cmd.packadd("dashboard-nvim")
      require("ak.config.intro")
    end, "VimEnter")
  end

  -- dressing:
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.select = function(...)
    vim.cmd.packadd("dressing.nvim")
    return vim.ui.select(...)
  end
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.ui.input = function(...)
    vim.cmd.packadd("dressing.nvim")
    return vim.ui.input(...)
  end

  Util.defer.on_events(function()
    vim.cmd.packadd("indent-blankline.nvim")
    require("ak.config.indent_blankline")
  end, lazyfile())

  Util.defer.on_events(function()
    vim.cmd.packadd("lualine.nvim")
    require("ak.config.lualine")
  end, verylazy())
end

return M
