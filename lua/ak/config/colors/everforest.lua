--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local name = "everforest"

-- lazygit colors are not always readable,  good light theme
Utils.color.add_toggle(name, {
  name = name,
  -- stylua: ignore
  flavours = {
    { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
    { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.everforest_background = flavour[2]
    vim.cmd.colorscheme(name)
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "everforest",
  callback = function()
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })

    -- todo-comments: the colors don't change across variants
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { bg = "#e67e80", fg = "#2d353b", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#e67e80" })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { bg = "#dbbc7f", fg = "#2d353b", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#dbbc7f" })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { bg = "#2563eb", fg = "#d3c6aa", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2563eb" })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { bg = "#10b981", fg = "#2d353b", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#10b981" })
  end,
})

local prefer_light = require("ak.color").prefer_light
vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 0
vim.g.everforest_background = "medium"
vim.o.background = prefer_light and "light" or "dark"
