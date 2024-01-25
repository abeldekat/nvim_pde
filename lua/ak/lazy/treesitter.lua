return {
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    config = function()
      require("ak.config.treesitter_autotag")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    config = function()
      require("ak.config.treesitter_context")
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    build = ":TSUpdate",
    init = function(plugin)
      require("lazy.core.loader").add_to_rtp(plugin)
      require("nvim-treesitter.query_predicates")
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      config = function()
        require("ak.config.treesitter_textobjects")
      end,
    },
    event = { "LazyFile", "VeryLazy" },
    cmd = { "TSUpdate" },
    keys = { { "<c-space>" }, { "<bs>", mode = "x" } },
    config = function()
      require("ak.config.treesitter")
    end,
  },
}
