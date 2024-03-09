--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯
local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("edge", {
  name = "edge",
  -- stylua: ignore
  flavours = {
    { "dark", "default" }, { "dark", "aura" }, { "dark", "neon" },
    { "light", "default" },
  },
  toggle = function(flavour)
    vim.o.background = flavour[1]
    vim.g.edge_style = flavour[2]
    vim.cmd.colorscheme("edge")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "edge",
  callback = function()
    -- the fg color is dimmed compared to lualine_c
    vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { link = "MiniStatuslineFilename" })

    -- todo-comments: the colors don't change across variants
    vim.api.nvim_set_hl(0, "MiniHipatternsFixme", { bg = "#ec7279", fg = "#2c2e34", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#ec7279" })
    vim.api.nvim_set_hl(0, "MiniHipatternsHack", { bg = "#deb974", fg = "#2c2e34", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#deb974" })
    vim.api.nvim_set_hl(0, "MiniHipatternsTodo", { bg = "#2563eb", fg = "#c5cdd9", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#2563eb" })
    vim.api.nvim_set_hl(0, "MiniHipatternsNote", { bg = "#10b981", fg = "#2c2e34", bold = true })
    vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = "#10b981" })
  end,
})

vim.g.edge_better_performance = 1
vim.g.edge_enable_italic = 0
vim.g.edge_style = "default"
vim.o.background = prefer_light and "light" or "dark"
