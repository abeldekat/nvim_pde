return {
  {
    "stevearc/conform.nvim",
    event = { "LspAttach", "BufWritePre" },
    config = function()
      require("ak.config.lang.formatting")
    end,
  },
}
