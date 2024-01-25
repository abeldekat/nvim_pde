return { -- previously: via init on VeryLazy
  "stevearc/conform.nvim",
  event = { "LspAttach", "BufWritePre" },
  config = function()
    require("ak.config.lang.formatting")
  end,
}
