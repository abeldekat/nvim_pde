local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"

-- M.styles_list = { 'vulgaris', 'multiplex', 'light' }
-- multiplex is greener.
require("bamboo").setup({
  dim_inactive = true,
  highlights = {
    MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" },
    MsgArea = { fg = "$grey" }, -- Area for messages and cmdline
  },
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>h",
  '<cmd>lua require("bamboo").toggle()<cr>',
  { desc = "Theme flavours", noremap = true, silent = true }
)
