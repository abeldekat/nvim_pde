--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

-- has its own toggle_style
require("onedark").setup({ -- the default is dark
  toggle_style_list = { "warm", "warmer", "light", "dark", "darker", "cool", "deep" },
  toggle_style_key = "<leader>a",
  style = "dark", -- ignored on startup, onedark.load must be used.
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "onedark",
  callback = function()
    -- MiniStatuslineFilename has a lighter fg color than lualine c:
    local hl_for_bg = vim.api.nvim_get_hl(0, { name = "MiniStatuslineFilename", link = false })
    vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = "fg", bg = hl_for_bg.bg })
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })
  end,
})
