local add_toggle = require("akshared.color_toggle").add
local prefer_light = require("ak.color").prefer_light
local name = "everforest"

-- lazygit colors are not always readable,  good light theme
add_toggle(name, {
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

    -- without undercurl:
    set_hl("ErrorText", palette.none, palette.none, "NONE", palette.red)
    set_hl("WarningText", palette.none, palette.none, "NONE", palette.yellow)
    set_hl("InfoText", palette.none, palette.none, "NONE", palette.blue)
    set_hl("HintText", palette.none, palette.none, "NONE", palette.green)

    set_hl("DiagnosticError", palette.red, palette.none)
    set_hl("DiagnosticWarn", palette.yellow, palette.none)
    set_hl("DiagnosticInfo", palette.blue, palette.none)
    set_hl("DiagnosticHint", palette.green, palette.none)

    -- vim.api.nvim_set_hl(0, "MiniJump2dSpot", { reverse = true })
    -- Same for all three groups:
    set_hl("MiniJump2dSpot", palette.orange, palette.none, "bold,nocombine")
    set_hl("MiniJump2dSpotAhead", palette.orange, palette.none, "bold,nocombine")
    set_hl("MiniJump2dSpotUnique", palette.orange, palette.none, "bold,nocombine")
    set_hl("MiniJump2dDim", palette.grey1, palette.none) -- comment color, no italic

    set_hl("MsgArea", palette.grey0, palette.none) -- Area for messages and cmdline
  end,
})

vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1
-- vim.g.everforest_disable_italic_comment = 1
vim.g.everforest_dim_inactive_windows = 1
vim.g.everforest_background = "medium"

vim.o.background = prefer_light and "light" or "dark"
