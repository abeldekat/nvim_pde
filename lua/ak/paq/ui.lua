local M = {}

local ui_spec = {
  "nvimdev/dashboard-nvim",
  { "stevearc/dressing.nvim", opt = true },
  "j-hui/fidget.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "nvim-lualine/lualine.nvim",
  "MunifTanjim/nui.nvim",
  "nvim-tree/nvim-web-devicons", -- also needed by oil in editor
}

function M.spec()
  return ui_spec
end

function M.setup()
  require("ak.config.intro").setup() -- event or not loaded

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

  require("fidget").setup({}) -- event
  require("ak.config.indent_blankline") -- event
  require("ak.config.lualine").init() -- event
  require("ak.config.lualine").setup()
end

return M
