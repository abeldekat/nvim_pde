-- Not actively used...
-- Add to colors.txt: sonokai
-- Last commit downloaded: "f59c796780655c3b9da442d310ad2f2d735f2e56"
local add_toggle = require("akshared.color_toggle").add

-- monokai variations
-- shusia, maia and espresso variants are modified versions of Monokai Pro
add_toggle("sonokai", {
  name = "sonokai",
  flavours = { "atlantis", "andromeda", "espresso", "shusia", "maia", "default" },
  toggle = function(flavour)
    vim.g.sonokai_style = flavour
    vim.cmd.colorscheme("sonokai")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "sonokai",
  group = vim.api.nvim_create_augroup("custom_highlights_sonokai", {}),
  callback = function()
    local config = vim.fn["sonokai#get_configuration"]()
    local palette = vim.fn["sonokai#get_palette"](config.style, config.colors_override)
    local set_hl = vim.fn["sonokai#highlight"]

    -- without undercurl:
    set_hl("ErrorText", palette.none, palette.none, "NONE", palette.red)
    set_hl("WarningText", palette.none, palette.none, "NONE", palette.yellow)
    set_hl("InfoText", palette.none, palette.none, "NONE", palette.blue)
    set_hl("HintText", palette.none, palette.none, "NONE", palette.green)

    set_hl("DiagnosticError", palette.red, palette.none)
    set_hl("DiagnosticWarn", palette.yellow, palette.none)
    set_hl("DiagnosticInfo", palette.blue, palette.none)
    set_hl("DiagnosticHint", palette.green, palette.none)

    set_hl("MsgArea", palette.grey_dim, palette.none) -- Area for messages and cmdline
  end,
})

vim.g.sonokai_better_performance = 1
vim.g.sonokai_enable_italic = 1
-- vim.g.sonokai_disable_italic_comment = 1
vim.g.sonokai_dim_inactive_windows = 1
vim.g.sonokai_style = "atlantis"
