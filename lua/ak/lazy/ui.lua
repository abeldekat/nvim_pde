--          ╭─────────────────────────────────────────────────────────╮
--          │                   Contains UI plugins                   │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local dashboard_now = Util.opened_without_arguments()

vim.o.statusline = " " -- wait till statusline plugin is loaded
return {
  {
    "nvimdev/dashboard-nvim",
    lazy = not dashboard_now,
    config = function() require("ak.config.ui.dashboard") end,
  },

  {
    "stevearc/dressing.nvim",
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy", -- event = lazyfile,
    config = function() require("ak.config.ui.indent_blankline") end,
  },

  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    config = function() require("ak.config.ui.mini_statusline") end,
  },

  -- {
  --   "nvim-lualine/lualine.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     local df = { statusline = { "dashboard" } }
  --     require("lualine").setup({
  --       options = { globalstatus = true, disabled_filetypes = df },
  --     })
  --   end,
  -- },
}
