---@diagnostic disable: undefined-global
-- Generate hues for shatur/neovim-ayu(mirage) using its bg and fg, with default MiniHues setup
-- local opts = { background = '#1F2430', foreground = '#CCCAC2' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated = {
  bg = '#1F2430', bg_edge = '#131723', bg_edge2 = '#050913', bg_mid = '#383d4a', bg_mid2 = '#525866',
  fg = '#CCCAC2', fg_edge = '#dddbd3', fg_edge2 = '#efede5', fg_mid = '#aeaca5', fg_mid2 = '#918f87',
  accent = '#b3c9ff', accent_bg = '#1F2430',

  azure = '#89dae2', azure_bg = '#004c51',
  blue = '#a1cffc', blue_bg = '#002a4c',
  cyan = '#9ddab7', cyan_bg = '#003c23',
  green = '#c9d094', green_bg = '#343700',
  orange = '#fab6b1', orange_bg = '#430f10',
  purple = '#ccc1fa', purple_bg = '#271a47',
  red = '#eeb6dc', red_bg = '#3c1131',
  yellow = '#edc191', yellow_bg = '#4a2b00',
}
-- stylua: ignore
local palette_fg = {
  accent = '#FFCC66', -- colors.accent

  -- Using colors set for MiniIcons*...
  -- colors.tag colors.entity colors.regexp colors.string
  azure = '#5CCFE6', blue = '#73D0FF', cyan = '#95E6CB', green = '#D5FF80',
  -- colors.keyword colors.lsp_parameter colors.error colors.special
  orange = '#FFAD66', purple = '#D3B8F9', red = '#FF6666', yellow = '#FFDFB3',
}

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local set = function()
  local p = require('mini.hues').get_palette()
  hi('Function', { fg = '#FFD173', bg = nil }) -- colors.func
  hi('Keyword', { fg = p.orange, bg = nil, bold = true })
  hi('MiniClueDescGroup', { fg = p.orange, bg = p.bg_edge })
end
Config.new_autocmd('ColorScheme', 'minihues-ayu-mirage', set, 'Hi for minihues-ayu-mirage')

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette_fg))
vim.g.colors_name = 'minihues-ayu-mirage'
