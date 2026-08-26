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
local palette_orange = '#FFAD66'
local palette_fg = {
  accent = '#FFCC66', -- colors.accent

  -- Colors set for MiniIcons*...
  azure = '#5CCFE6', -- colors.tag
  blue = '#73D0FF', -- colors.entity
  cyan = '#95E6CB', -- colors.regexp
  green = '#D5FF80', -- colors.string
  orange = palette_orange, -- colors.keyword
  purple = '#D3B8F9', -- colors.lsp_parameter
  red = '#FF6666', -- colors.error
  yellow = '#FFDFB3', -- colors.special
}

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local set = function()
  hi('Function', { fg = '#FFD173', bg = nil }) -- colors.func
  hi('Keyword', { fg = palette_orange, bg = nil, bold = true })
end
Config.new_autocmd('ColorScheme', 'minihues-ayu-mirage', set, 'Hi for minihues-ayu-mirage')

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette_fg))
vim.g.colors_name = 'minihues-ayu-mirage'
