--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
local name = "gruvbox-material"

Utils.color.add_toggle("*material", {
  name = name,
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.gruvbox_material_background = flavour[2]
    vim.cmd.colorscheme(name)
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "gruvbox-material",
  callback = function()
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })

    -- todo-comments: the colors don't change across variants
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { bg = "#ea6962", fg = "#32302f", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ea6962" })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { bg = "#d8a657", fg = "#32302f", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#d8a657" })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { bg = "#2563eb", fg = "#d4be98", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2563eb" })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { bg = "#10b981", fg = "#32302f", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#10b981" })
  end,
})

vim.g.gruvbox_material_foreground = "material" -- "mix", "original"
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_foreground = "material"
-- vim.g.gruvbox_material_diagnostic_text_highlight = 1
vim.o.background = prefer_light and "light" or "dark"
