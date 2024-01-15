return {
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    config = function()
      require("ak.config.linting")
    end,
  },
}
