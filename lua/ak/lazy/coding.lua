--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins for code modificaton          │
--          ╰─────────────────────────────────────────────────────────╯

return {

  -- ── verylazy, previously insertenter ───────────────────────────────────────────────────────

  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = function() require("ak.config.coding.autopairs") end,
  },

  { -- Lazy loading benefit: +-5 ms
    "hrsh7th/nvim-cmp",
    event = "VeryLazy",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function() require("ak.config.coding.cmp") end,
  },

  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "VeryLazy",
    config = function() require("ak.config.coding.LuaSnip") end,
  },

  -- ── verylazy ──────────────────────────────────────────────────────────

  {
    "monaqa/dial.nvim",
    event = "VeryLazy",
    config = function()
      require("ak.config.coding.dial")

      --          ╭─────────────────────────────────────────────────────────╮
      --          │           Efficiency: Also setup mini plugins           │
      --          ╰─────────────────────────────────────────────────────────╯
      require("ak.config.coding.mini_surround")
      require("ak.config.coding.mini_comment")
      require("ak.config.coding.mini_operators")
    end,
  },

  -- ── on-demand ─────────────────────────────────────────────────────────

  {
    "LudoPinelli/comment-box.nvim",
    keys = { { "<leader>bL", desc = "Load comment-box" } },
    config = function() require("ak.config.coding.comment_box") end,
  },
}
