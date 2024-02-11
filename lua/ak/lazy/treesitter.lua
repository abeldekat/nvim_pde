return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    config = function() require("ak.config.treesitter.treesitter") end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy", -- event = lazyfile(),
    config = function() require("ak.config.treesitter.autotag") end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy", -- event = lazyfile(),
    config = function() require("ak.config.treesitter.context") end,
  },
}
