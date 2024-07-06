--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

-- has its own toggle_style
require("onedark").setup({ -- the default is dark
  toggle_style_list = { "warm", "warmer", "light", "dark", "darker", "cool", "deep" },
  toggle_style_key = "<leader>h",
  style = "dark", -- ignored on startup, onedark.load must be used.
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "onedark",
  callback = function()
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
    local hl_for_msg_area = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    vim.api.nvim_set_hl(0, "MsgArea", { fg = hl_for_msg_area.fg }) -- Area for messages and cmdline
  end,
})
