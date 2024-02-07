--          ╭─────────────────────────────────────────────────────────╮
--          │            onedark supports mini.statusline             │
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
    vim.cmd("highlight! link MiniStatuslineModeNormal MiniStatuslineDevinfo")
  end,
})
