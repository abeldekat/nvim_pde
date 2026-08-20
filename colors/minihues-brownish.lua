-- Colorscheme randomhue, repeat "<leader>oc"(Next theme variant)
-- :=MiniHues.get_palette()
-- Nice in combination terminal colorscheme "Bamboo"

local palette = {
  accent = '#9fd7af',
  accent_bg = '#17271c',
  azure = '#8bd3ec',
  azure_bg = '#004354',
  bg = '#17271c',
  bg_edge = '#0b1b10',
  bg_edge2 = '#010c04',
  bg_mid = '#304135',
  bg_mid2 = '#4a5c4f',
  blue = '#b0c6fc',
  blue_bg = '#111f49',
  cyan = '#8dd9c6',
  cyan_bg = '#00483c',
  fg = '#c2c9c4',
  fg_edge = '#d4dbd6',
  fg_edge2 = '#e7eee9',
  fg_mid = '#a5aca7',
  fg_mid2 = '#888e8a',
  green = '#b4d29c',
  green_bg = '#193000',
  orange = '#f5b69e',
  orange_bg = '#411200',
  purple = '#d9b9ed',
  purple_bg = '#2f143e',
  red = '#f2b2c8',
  red_bg = '#3e0d23',
  yellow = '#dec48b',
  yellow_bg = '#463400',
}

require('mini.hues').apply_palette(palette)
vim.g.colors_name = 'minihues-brownish'
