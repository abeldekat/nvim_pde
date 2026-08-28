-- Generate hues for ribru17/bamboo(vulgaris) using its bg0 and fg, with default MiniHues setup
-- local opts = { background = '#252623', foreground = '#f1e9d2' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated = {
  bg = '#252623', bg_edge = '#181916', bg_edge2 = '#090a08', bg_mid = '#424440', bg_mid2 = '#62635f',
  fg = '#f1e9d2', fg_edge = '#f8f0d9', fg_edge2 = '#fff7e0', fg_mid = '#cec6b0', fg_mid2 = '#aaa38d',
  accent = '#e0f2b7', accent_bg = '#252623',
  azure_bg = '#003351', cyan_bg = '#004e4f', green_bg = '#003515', 
  orange_bg = '#4a2700', purple_bg = '#3b1437', red_bg = '#451017',
}
local palette_bg = { blue_bg = '#68aee8', yellow_bg = '#e2c792' }
-- stylua: ignore
local palette_fg = {
  blue = '#57a5e5', cyan = '#70c2be', green = '#8fb573', orange = '#ff9966',
  purple = '#df73ff', red = '#e75a7c', yellow = '#dbb651',
}
-- No azure. Use blue. Bamboo also defines grey and coral
palette_fg.azure = palette_fg.blue

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette_bg, palette_fg))
vim.g.colors_name = 'minihues-bamboo'
