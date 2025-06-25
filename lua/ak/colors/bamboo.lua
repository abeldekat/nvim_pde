local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

-- M.styles_list = { 'vulgaris', 'multiplex', 'light' }
-- multiplex is greener.
require("bamboo").setup({
  dim_inactive = true,
  highlights = {
    MsgArea = { fg = "$grey" }, -- Area for messages and cmdline
    MiniJump2dSpot = { fg = "$orange", bg = nil, bold = true, nocombine = true }, -- reddish
    MiniJump2dSpotAhead = { link = "MiniJump2dSpot" },
    MiniJump2dSpotUnique = { link = "MiniJump2dSpot" },
  },
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>h",
  '<cmd>lua require("bamboo").toggle()<cr>',
  { desc = "Theme flavours", noremap = true, silent = true }
)
