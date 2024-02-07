local Util = require("ak.util")
-- local lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

return {
  {
    "nvimdev/dashboard-nvim",
    event = function()
      return Util.opened_without_arguments() and { "VimEnter" } or {}
    end,
    config = function()
      require("ak.config.intro")
    end,
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
    config = function()
      require("ak.config.indent_blankline")
    end,
  },

  {
    "echasnovski/mini.statusline",
    lazy = false,
    config = function()
      require("ak.config.mini_statusline")
    end,
  },

  --          ╭─────────────────────────────────────────────────────────╮
  --          │     lualine has been replaced with mini.statusline      │
  --          │         keep the config to compare if necessary         │
  --          ╰─────────────────────────────────────────────────────────╯
  -- {
  --   "nvim-lualine/lualine.nvim",
  --   init = function()
  --     --          ╭─────────────────────────────────────────────────────────╮
  --     --          │   no statusline on dashboard, empty statusline until    │
  --     --          │                    lualine is loaded                    │
  --     --          ╰─────────────────────────────────────────────────────────╯
  --     if vim.fn.argc(-1) > 0 then
  --       vim.o.statusline = " "
  --     else
  --       vim.o.laststatus = 0
  --     end
  --   end,
  --   event = "VeryLazy",
  --   config = function()
  --     local opts = {
  --       options = {
  --         icons_enabled = false,
  --         globalstatus = true,
  --         component_separators = "|",
  --         section_separators = "",
  --         disabled_filetypes = { statusline = { "dashboard" } },
  --       },
  --       sections = {
  --         lualine_c = {
  --           { "filename", path = 1, shortening_target = 40, symbols = { unnamed = "" } },
  --         },
  --       },
  --     }
  --
  --     require("lualine").setup(opts)
  --   end,
  -- },
}
