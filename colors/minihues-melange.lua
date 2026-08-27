-- NOTE: Melange's philosophy is different: Warm control flow, bright data...
-- Generate hues for savq/melange using its bg and fg, with default MiniHues setup
-- local opts = { background = '#292522', foreground = '#ECE1D7' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated = {
  bg = '#292522', bg_edge = '#1c1815', bg_edge2 = '#0c0907', bg_mid = '#46423e', bg_mid2 = '#65605c',
  fg = '#ECE1D7', fg_edge = '#f5eae0', fg_edge2 = '#fff4ea', fg_mid = '#cabfb5', fg_mid2 = '#a89d94',
  accent = '#ffd3af', accent_bg = '#292522',

  azure = '#aaebff', azure_bg = '#004655',
  blue = '#bed5ff', blue_bg = '#12234c',
  cyan = '#aaf5e0', cyan_bg = '#00483b',
  green = '#d2eeb6', green_bg = '#1e3200',
  orange = '#ffccb8', orange_bg = '#441402',
  purple = '#edd0ff', purple_bg = '#321843',
  red = '#ffcbe2', red_bg = '#421128',
  yellow = '#fce0a6', yellow_bg = '#493400',
}
-- stylua: ignore
local palette_b_fg_bright = {
  blue = '#A3A9CE', cyan = '#89B3B6', green = '#85B695', red = '#D47766', yellow = '#EBC06D',
}
-- stylua: ignore
local palette_c_fg = {
  blue = '#7F91B2', cyan = '#7B9695', green = '#78997A', red = '#BD8183', yellow = '#E49B5D',
}
-- stylua: ignore
local palette_d_bg = {
  blue_bg = '#273142', cyan_bg = '#253333', green_bg = '#233524', red_bg = '#7D2A2F', yellow_bg = '#8B7449',
}

local use_bright = true
local palette_fg = use_bright and palette_b_fg_bright or palette_c_fg

-- Melange does not define orange. Use yellow
palette_fg.orange = palette_c_fg.yellow
palette_d_bg.orange_bg = palette_d_bg.yellow_bg
-- Melange does not define purple, MiniHues does not have magenta. Use melange magenta for purple
palette_fg.purple = use_bright and '#CF9BC2' or '#B380B0'
palette_d_bg.purple_bg = '#422741'

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette_d_bg, palette_fg))
vim.g.colors_name = 'minihues-melange'
