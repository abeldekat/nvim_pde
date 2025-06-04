-- Not actively used...
-- Last commit downloaded: 8dc187c5bbfd0127eb0ebc3b4f0968bba6716264
-- Add to colors.txt: edge

local add_toggle = require("akshared.color_toggle").add
local prefer_light = require("ak.color").prefer_light

add_toggle("edge", {
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

vim.g.edge_better_performance = 1
vim.g.edge_enable_italic = 0
vim.g.edge_style = "default"
vim.o.background = prefer_light and "light" or "dark"
