-- NOTE: Melange's philosophy is different: Warm control flow, bright data...
-- This version only uses its colors, without changing mini.hues highlights
-- Generate hues for savq/melange using its bg and fg
-- local opts = { background = '#292522', foreground = '#ECE1D7', saturation = 'low' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated_low = {
  bg = "#292522", bg_edge = "#1c1815", bg_edge2 = "#0c0907", bg_mid = "#46423e", bg_mid2 = "#65605c",
  fg = "#ECE1D7", fg_edge = "#f5eae0", fg_edge2 = "#fff4ea", fg_mid = "#cabfb5", fg_mid2 = "#a89d94",
  accent = "#f8dec9", accent_bg = "#292522",

  azure = "#c7eaf6", azure_bg = "#0a2a33",
  blue = "#d6e4ff", blue_bg = "#1c253a",
  cyan = "#c9ece1", cyan_bg = "#0d2c25",
  green = "#dbe9cd", green_bg = "#202a14",
  orange = "#fcdbd0", orange_bg = "#371f17",
  purple = "#ebdcf8", purple_bg = "#2c2035",
  red = "#fad9e5", red_bg = "#351d27",
  yellow = "#f0e2c6", yellow_bg = "#2f240d"
}

-- stylua: ignore
-- local generated_medium = {
--   bg = "#292522", bg_edge = "#1c1815", bg_edge2 = "#0c0907", bg_mid = "#46423e", bg_mid2 = "#65605c",
--   fg = "#ECE1D7", fg_edge = "#f5eae0", fg_edge2 = "#fff4ea", fg_mid = "#cabfb5", fg_mid2 = "#a89d94",
--   accent = "#ffd3af", accent_bg = "#292522",
--
--   azure = "#aaebff", azure_bg = "#004655",
--   blue = "#bed5ff", blue_bg = "#12234c",
--   cyan = "#aaf5e0", cyan_bg = "#00483b",
--   green = "#d2eeb6", green_bg = "#1e3200",
--   orange = "#ffccb8", orange_bg = "#441402",
--   purple = "#edd0ff", purple_bg = "#321843",
--   red = "#ffcbe2", red_bg = "#421128",
--   yellow = "#fce0a6", yellow_bg = "#493400"
-- }

-- Melange's palette has sections "a"(grays), "b"(fg bright), "c"(fg) and "d"(bg)
-- Colors azure, orange and purple are absent. Melange has magenta
local yellow, yellow_bg = '#EBC06D', '#8B7449'
local yellow_from_c = '#E49B5D'
local magenta, magenta_bg = '#CF9BC2', '#422741'
-- local magenta_from_c = '#B380b0'
-- stylua: ignore
local palette = { -- from b and d sections
  accent = yellow,

  -- azure = -- not defined
  blue = '#A3A9CE', blue_bg = '#273142',
  cyan = '#89B3B6', cyan_bg = '#253333',
  -- green = '#85B695', green_bg = '#233524', -- too dim
  orange = yellow_from_c, orange_bg = yellow_bg,
  purple = magenta, purple_bg = magenta_bg,
  red = '#D47766', red_bg = '#7D2A2F',
  yellow = yellow, yellow_bg = yellow_bg
}

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated_low, palette))
vim.g.colors_name = 'minimelange'
