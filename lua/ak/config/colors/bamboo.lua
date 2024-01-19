local prefer_light = require("ak.color").prefer_light

-- regular vulgaris greener multiplex light mode
vim.o.background = prefer_light and "light" or "dark"
require("bamboo").setup({
  style = "vulgaris",
  toggle_style_key = "<leader>a",
  dim_inactive = true,
})
