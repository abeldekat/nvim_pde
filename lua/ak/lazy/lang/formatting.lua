return { -- previously: via init on VeryLazy
  "stevearc/conform.nvim",
  event = { "LspAttach", "BufWritePre" },
  init = function()
    require("ak.config.lang.formatting").init()
  end,
  config = function()
    require("ak.config.lang.formatting").setup()
  end,
}
