return {
  {
    "mfussenegger/nvim-lint",
    event = "LazyFile",
    config = function()
      require("ak.config.lang.linting")
    end,
  },
}
