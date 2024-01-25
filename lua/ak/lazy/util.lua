return {
  -- {
  --   "folke/persistence.nvim",
  --   event = "BufReadPre",
  --   config = function()
  --     require("ak.config.persistence")
  --   end,
  -- },

  {
    "dstein64/vim-startuptime",
    keys = { { "<leader>ms", desc = "Startuptime" } },
    config = function()
      require("ak.config.startuptime")
    end,
  },

  {
    "jpalardy/vim-slime",
    keys = { { "<leader>mr", desc = "Repl" } },
    config = function()
      require("ak.config.repl")
    end,
  },
}
