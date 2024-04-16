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
  group = vim.api.nvim_create_augroup("custom_highlights_edge", {}),
  callback = function()
    local config = vim.fn["edge#get_configuration"]()
    local palette = vim.fn["edge#get_palette"](config.style, config.dim_foreground, config.colors_override)
    local set_hl = vim.fn["edge#highlight"]

    set_hl("MiniStatuslineModeNormal", palette.grey, palette.bg1, "bold") -- like filename

    set_hl("MiniHipatternsFixme", palette.bg0, palette.red, "bold")
    set_hl("MiniHipatternsHack", palette.bg0, palette.yellow, "bold")
    set_hl("MiniHipatternsTodo", palette.bg0, palette.blue, "bold")
    set_hl("MiniHipatternsNote", palette.bg0, palette.green, "bold")

    -- without undercurl:
    set_hl("DiagnosticError", palette.red, palette.none)
    set_hl("DiagnosticWarn", palette.yellow, palette.none)
    set_hl("DiagnosticInfo", palette.blue, palette.none)
    set_hl("DiagnosticHint", palette.green, palette.none)
  end,
})

vim.g.edge_better_performance = 1
vim.g.edge_enable_italic = 0
vim.g.edge_style = "default"
vim.o.background = prefer_light and "light" or "dark"
