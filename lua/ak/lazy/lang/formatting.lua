return {
  "stevearc/conform.nvim",
  event = { "LspAttach", "BufWritePre" }, -- Previously: via init on VeryLazy
  cmd = "ConformInfo",
  init = function()
    require("ak.config.lang.formatting").init()
  end,
  config = function()
    require("ak.config.lang.formatting").setup()
  end,
}
