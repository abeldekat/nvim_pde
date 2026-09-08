-- NOTE: Melange's philosophy is different: Warm control flow, bright data...
-- This version only uses its colors, without changing mini.hues highlights
-- Generate hues for savq/melange using its bg and fg, with default MiniHues setup
-- local opts = { background = '#292522', foreground = '#ECE1D7' }
-- require('mini.hues').setup(opts)

-- stylua: ignore start
local generated = {
  bg = '#292522', bg_edge = '#1c1815', bg_edge2 = '#0c0907', bg_mid = '#46423e', bg_mid2 = '#65605c',
  fg = '#ECE1D7', fg_edge = '#f5eae0', fg_edge2 = '#fff4ea', fg_mid = '#cabfb5', fg_mid2 = '#a89d94',
  accent = '#ffd3af', accent_bg = '#292522',
  azure = "#aaebff", azure_bg = '#004655',
  purple = "#edd0ff", purple_bg = "#321843",
}

-- Melange palette defines sections "a"(grays), "b"(fg bright), "c"(fg) and "d"(bg)
-- Melange does not define azure, orange and purple. It does define magenta
local b_fg = { blue = '#A3A9CE', cyan = '#89B3B6', green = '#85B695', red = '#D47766', yellow = '#EBC06D' }
-- local c = { blue = '#7F91B2', cyan = '#7B9695', green = '#78997A', red = '#BD8183', yellow = '#E49B5D' }
local d_bg = {
  blue_bg = '#273142', cyan_bg = '#253333', green_bg = '#233524', red_bg = '#7D2A2F', yellow_bg = '#8B7449'
}
-- stylua: ignore end

-- Use c.yellow for orange
b_fg.orange = '#E49B5D'
d_bg.orange_bg = d_bg.yellow_bg

-- Melange green is not bright enough for mini.hues. Use generated
b_fg.green = '#d2eeb6'
d_bg.green_bg = '#1e3200'

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, d_bg, b_fg))
vim.g.colors_name = 'minimelange'
