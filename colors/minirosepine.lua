-- Generate hues for rose-pine/neovim(main) using its base and text, with default MiniHues setup
-- local opts = { background = '#191724', foreground = '#e0def4' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local main = {
  -- _nc = '#16141f', base = '#191724', surface = '#1f1d2e', overlay = '#26233a', muted = '#6e6a86', subtle = '#908caa', --
  -- highlight_low = '#21202e', highlight_med = '#403d52', highlight_high = '#524f67', none = 'NONE', --
  -- text = '#e0def4',

  love = '#eb6f92', -- same as in moon
  gold = '#f6c177', -- same as in moon
  rose_from_moon = '#ea9a97', -- rose = '#ebbcba',
  -- pine = '#31748f', -- too dim
  -- foam = '#9ccfd8', -- too dim
  iris = '#c4a7e7', -- same as in moon
  -- leaf = '#95b1ac', -- too dim 
}

-- stylua: ignore
local generated = {
  bg = "#191724", bg_edge = "#100e1a", bg_edge2 = "#05040d", bg_mid = "#373544", bg_mid2 = "#575565",
  fg = "#e0def4", fg_edge = "#eae8fe", fg_edge2 = "#eeedff", fg_mid = "#bcbacf", fg_mid2 = "#9896ab",
  accent = "#d7d0ff", accent_bg = "#191724",

  azure = "#a8e8ff", azure_bg = "#003e4e",
  blue = "#c0d4ff", blue_bg = "#0a143d",
  cyan = "#a6f3e1", cyan_bg = "#00453a",
  green = "#ccedb7", green_bg = "#142b00",
  orange = "#ffccb5", orange_bg = "#3d1200",
  purple = "#f1d0ff", purple_bg = "#250932",
  red = "#ffc9dd", red_bg = "#330319",
  yellow = "#f7dfa4", yellow_bg = "#423100"
}

local palette = {
  accent = main.rose_from_moon,

  -- azure blue cyan green: colors are too dim
  orange = main.rose_from_moon,
  purple = main.iris,
  red = main.love,
  yellow = main.gold,
}

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette))
vim.g.colors_name = 'minirosepine'
