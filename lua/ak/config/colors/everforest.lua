--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light
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
  group = vim.api.nvim_create_augroup("custom_highlights_everforest", {}),
  callback = function()
    local config = vim.fn["everforest#get_configuration"]()
    local palette = vim.fn["everforest#get_palette"](config.background, config.colors_override)
    local set_hl = vim.fn["everforest#highlight"] -- group fg bg

    -- Override MiniStatuslineFilename, which is just "Grey"
    set_hl("MiniStatuslineFilename", palette.grey1, palette.bg1) -- like fileinfo
    -- Override normal
    set_hl("MiniStatuslineModeNormal", palette.grey1, palette.bg1, "bold") -- like fileinfo

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

vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1
-- vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_dim_inactive_windows = 1
vim.g.everforest_background = "medium"

vim.o.background = prefer_light and "light" or "dark"
