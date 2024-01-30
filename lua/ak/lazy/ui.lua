local Util = require("ak.util")

-- local function lazyfile()
--   return { "BufReadPost", "BufNewFile", "BufWritePre" }
-- end

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
    lazy = true,
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
    -- event = lazyfile(),
    event = "VeryLazy",
    config = function()
      require("ak.config.indent_blankline")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    init = function()
      require("ak.config.lualine_init")
    end,
    event = "VeryLazy",
    config = function()
      require("ak.config.lualine")
    end,
  },
}
