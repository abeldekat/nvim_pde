return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("ak.config.pairs")
    end,
  },

  {
    "LudoPinelli/comment-box.nvim",
    keys = { "<leader>bb", "<leader>bl" }, -- lazy only on normal mode keys
    config = function()
      require("ak.config.comment_box")
    end,
  },

  {
    "numToStr/Comment.nvim", -- the plugin itself creates the gc and gb mappings
    keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    config = function()
      require("ak.config.comment")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is old
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
    "monaqa/dial.nvim",
    keys = { "<C-a>", "<C-x" },
    config = function()
      require("ak.config.dial")
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    keys = { { "<tab>", mode = { "i", "s" } }, { "<s-tab>", mode = { "i", "s" } } },
    config = function()
      require("ak.config.snip")
    end,
  },

  {
    "gbprod/substitute.nvim", -- substitute, exchange and multiply(not used often, not lazy)
    -- Optimize: define lazy keys only for normal mode
    -- keys = { { "gs", mode = { "n", "x" } }, { "gx", mode = { "n", "x" } } },
    keys = { "gs", "gx" },
    config = function()
      require("ak.config.substitute")
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    -- Optimize: define lazy keys only for normal mode
    -- { "<C-g>z", mode = "i" }, { "<C-g>Z", mode = "i" }, { "Z", mode = "x" }, { "gZ", mode = "x" },
    keys = { "yz", "yzz", "yZ", "yZZ", "dz", "cz", "cZ" },
    config = function()
      require("ak.config.surround")
    end,
  },
}
