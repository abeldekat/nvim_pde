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
  group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
  callback = function()
    local config = vim.fn["gruvbox_material#get_configuration"]()
    local palette = vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
    local set_hl = vim.fn["gruvbox_material#highlight"]

    set_hl("MiniStatuslineModeNormal", palette.grey2, palette.bg_statusline1, "bold") -- like filename

    -- without undercurl:
    set_hl("ErrorText", palette.none, palette.none, "NONE", palette.red)
    set_hl("WarningText", palette.none, palette.none, "NONE", palette.yellow)
    set_hl("InfoText", palette.none, palette.none, "NONE", palette.blue)
    set_hl("HintText", palette.none, palette.none, "NONE", palette.green)

    set_hl("DiagnosticError", palette.red, palette.none)
    set_hl("DiagnosticWarn", palette.yellow, palette.none)
    set_hl("DiagnosticInfo", palette.blue, palette.none)
    set_hl("DiagnosticHint", palette.green, palette.none)

    set_hl("MsgArea", palette.grey1, palette.none) -- Area for messages and cmdline
  end,
})

vim.g.gruvbox_material_foreground = "material" -- "mix", "original"
vim.g.gruvbox_material_better_performance = 1
vim.g.ruvbox_material_enable_italic = 1
-- vim.g.gruvbox_material_disable_italic_comment = 1
vim.g.gruvbox_material_background = "soft"
vim.g.gruvbox_material_foreground = "material"
vim.o.background = prefer_light and "light" or "dark"
