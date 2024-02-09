return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy", -- lazyfile
    config = function()
      require("ak.config.lang.linting")
    end,
  },
}
