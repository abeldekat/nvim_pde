-- Not actively used...
-- Last commit downloaded: 67a74c275d1116d575ab25485d1bfa6b2a9c38a6
-- Add to colors.txt: onedark
vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "onedark",
  callback = function()
    local hl_for_msg_area = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    vim.api.nvim_set_hl(0, "MsgArea", { fg = hl_for_msg_area.fg }) -- Area for messages and cmdline
  end,
})

-- has its own toggle_style
require("onedark").setup({ -- the default is dark
  toggle_style_list = { "warm", "warmer", "light", "dark", "darker", "cool", "deep" },
  style = "dark", -- ignored on startup, onedark.load must be used.
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>h",
  '<cmd>lua require("onedark").toggle()<cr>',
  { desc = "Theme flavours", noremap = true, silent = true }
)
