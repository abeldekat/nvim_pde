--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

-- NOTE: Mini.pick current line not different

-- has its own toggle_style
require("onedark").setup({ -- the default is dark
  toggle_style_list = { "warm", "warmer", "light", "dark", "darker", "cool", "deep" },
  toggle_style_key = "<leader>h",
  style = "dark", -- ignored on startup, onedark.load must be used.
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "onedark",
  callback = function()
    -- MiniStatuslineFilename has a lighter fg color than lualine c:
    local hl_for_bg = vim.api.nvim_get_hl(0, { name = "MiniStatuslineFilename", link = false })
    vim.api.nvim_set_hl(0, "MiniStatuslineFilename", { fg = "fg", bg = hl_for_bg.bg })
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })

    local hl_error = vim.api.nvim_get_hl(0, { name = "DiagnosticError", link = false })
    local hl_warn = vim.api.nvim_get_hl(0, { name = "DiagnosticWarn", link = false })
    local hl_info = vim.api.nvim_get_hl(0, { name = "DiagnosticInfo", link = false })
    local hl_hint = vim.api.nvim_get_hl(0, { name = "DiagnosticHint", link = false })
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { fg = hl_for_bg.bg, bg = hl_error.fg, bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { fg = hl_for_bg.bg, bg = hl_warn.fg, bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { fg = hl_for_bg.bg, bg = hl_info.fg, bold = true })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { fg = hl_for_bg.bg, bg = hl_hint.fg, bold = true })

    local hl_for_msg_area = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
    vim.api.nvim_set_hl(0, "MsgArea", { fg = hl_for_msg_area.fg }) -- Area for messages and cmdline
  end,
})
