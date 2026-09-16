-- NOTE: Melange's philosophy is different: Warm control flow, bright data...
-- This version only uses its colors, without changing mini.hues highlights
-- Generate hues for savq/melange using its bg and fg
-- local opts = { background = '#292522', foreground = '#ECE1D7' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated_medium = {
  bg = "#292522", bg_edge = "#1c1815", bg_edge2 = "#0c0907", bg_mid = "#46423e", bg_mid2 = "#65605c",
  fg = "#ECE1D7", fg_edge = "#f5eae0", fg_edge2 = "#fff4ea", fg_mid = "#cabfb5", fg_mid2 = "#a89d94",
  accent = "#ffd3af", accent_bg = "#292522",

  azure = "#aaebff", azure_bg = "#004655",
  blue = "#bed5ff", blue_bg = "#12234c",
  cyan = "#aaf5e0", cyan_bg = "#00483b",
  green = "#d2eeb6", green_bg = "#1e3200",
  orange = "#ffccb8", orange_bg = "#441402",
  purple = "#edd0ff", purple_bg = "#321843",
  red = "#ffcbe2", red_bg = "#421128",
  yellow = "#fce0a6", yellow_bg = "#493400"
}

-- Melange's palette has sections "a"(grays), "b"(fg bright), "c"(fg) and "d"(bg)
-- Colors azure, orange and purple are absent. Melange has magenta
local green_from_summer, green_bg_from_summer = '#d1db9f', '#313600'
local magenta, magenta_bg = '#CF9BC2', '#422741'
-- local magenta_from_c = '#B380b0'
local yellow, yellow_bg = '#EBC06D', '#8B7449'
local yellow_from_c = '#E49B5D'

-- stylua: ignore
local palette = { -- from b and d sections
  accent = yellow,

  -- azure = -- not defined
  blue = '#A3A9CE', blue_bg = '#273142',
  cyan = '#89B3B6', cyan_bg = '#253333',

  -- green = '#85B695', green_bg = '#233524', -- melange's green is too dim
  green = green_from_summer, green_bg = green_bg_from_summer,

  orange = yellow_from_c, orange_bg = yellow_bg,
  purple = magenta, purple_bg = magenta_bg,
  red = '#D47766', red_bg = '#7D2A2F',
  yellow = yellow, yellow_bg = yellow_bg
}

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated_medium, palette))
vim.g.colors_name = 'minimelange'
