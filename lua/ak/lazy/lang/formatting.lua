return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  -- keys = { "<leader>cF", mode = { "n", "v" } }, -- format injected not needed as lazy key
  init = function()
    require("ak.config.lang.formatting").init()
  end,
  config = function()
    require("ak.config.lang.formatting").setup()
  end,
}
