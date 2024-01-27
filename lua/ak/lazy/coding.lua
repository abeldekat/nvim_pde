return {

  -- ── insertenter ───────────────────────────────────────────────────────

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("ak.config.pairs")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("ak.config.completion")
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    config = function()
      require("ak.config.snip")
    end,
  },

  -- ── verylazy ──────────────────────────────────────────────────────────

  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    config = function()
      require("ak.config.dial")
    end,
  },

  {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    config = function()
      require("ak.config.substitute")
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("ak.config.surround")
    end,
  },

  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("ak.config.comment")
    end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  -- { -- duplicate tag in helpfile
  --   "LudoPinelli/comment-box.nvim",
  --   keys = { { "<leader>bL", desc = "Load comment-box" } },
  --   config = function()
  --     require("ak.config.comment_box")
  --   end,
  -- },
}
