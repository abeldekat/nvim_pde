--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")

-- monokai variations
-- shusia, maia and espresso variants are modified versions of Monokai Pro
Utils.color.add_toggle("sonokai", {
  name = "sonokai",
  flavours = { "andromeda", "espresso", "atlantis", "shusia", "maia", "default" },
  toggle = function(flavour)
    vim.g.sonokai_style = flavour
    vim.cmd.colorscheme("sonokai")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "sonokai",
  callback = function()
    -- the fg color is dimmed compared to lualine_c
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })

    -- todo-comments: the colors don't change across variants
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { bg = "#fb617e", fg = "#2b2d3a", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#fb617e" })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { bg = "#edc763", fg = "#2b2d3a", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#edc763" })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { bg = "#2563eb", fg = "#e1e3e4", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2563eb" })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { bg = "#10b981", fg = "#2b2d3a", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#10b981" })
  end,
})

vim.g.sonokai_better_performance = 1
vim.g.sonokai_enable_italic = 0
vim.g.sonokai_disable_italic_comment = 1
vim.g.sonokai_dim_inactive_windows = 1
-- vim.g.sonokai_diagnostic_text_highlight = 1
vim.g.sonokai_style = "andromeda"
