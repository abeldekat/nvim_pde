return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function() require("ak.config.lang.linting") end,
  },
}
