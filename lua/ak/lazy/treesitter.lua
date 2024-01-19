return {
  {
    "windwp/nvim-ts-autotag",
    event = "LazyFile",
    config = function()
      require("nvim-ts-autotag").setup()
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
    init = function(plugin) --> Only for lazy.nvim...
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
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
    cmd = { "TSUpdate" }, -- cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = { { "<c-space>" }, { "<bs>", mode = "x" } },
    config = function()
      require("ak.config.treesitter")
    end,
  },
}
