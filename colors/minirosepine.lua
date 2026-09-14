-- Generate hues for rose-pine/neovim(main) using its base and text
-- local opts = { background = '#191724', foreground = '#e0def4' }
-- require('mini.hues').setup(opts)

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

local rose_from_moon_variant = '#ea9a97' -- main is too light
local pine_from_moon_variant = '#3e8fb0' -- main is too dark
local palette = {
  accent = rose_from_moon_variant,

  -- azure blue cyan green: colors are too dim
  -- pine = '#31748f', foam = '#9ccfd8', leaf = '#95b1ac'
  -- azure = foam, blue = pine, cyan = foam, green = leaf,

  -- MiniHues: The generated azure is too light in this context
  -- Set rose(much darker) to azure. MiniHues uses azure for 'Function' hl
  azure = rose_from_moon_variant,
  green = pine_from_moon_variant,

  orange = rose_from_moon_variant,
  purple = '#c4a7e7', -- iris
  red = '#eb6f92', -- love
  yellow = '#f6c177', --gold
}

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette))
vim.g.colors_name = 'minirosepine'
