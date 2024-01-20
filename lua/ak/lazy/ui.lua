return {
  {
    "nvimdev/dashboard-nvim",
    event = function() -- vimenter
      if require("ak.config.intro").should_load() then
        return { "VimEnter" }
      else
        return {}
      end
    end,
    config = function()
      require("ak.config.intro").setup()
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
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("fidget").setup({})
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    event = "LazyFile",
    config = function()
      require("ak.config.indent_blankline")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    init = function()
      require("ak.config.lualine").init()
    end,
    config = function()
      require("ak.config.lualine").setup()
    end,
  },
}
