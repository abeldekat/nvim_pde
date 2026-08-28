-- NOTE: Melange's philosophy is different: Warm control flow, bright data...
-- Generate hues for savq/melange using its bg and fg, with default MiniHues setup
-- local opts = { background = '#292522', foreground = '#ECE1D7' }
-- require('mini.hues').setup(opts)

-- stylua: ignore
local generated = {
  bg = '#292522', bg_edge = '#1c1815', bg_edge2 = '#0c0907', bg_mid = '#46423e', bg_mid2 = '#65605c',
  fg = '#ECE1D7', fg_edge = '#f5eae0', fg_edge2 = '#fff4ea', fg_mid = '#cabfb5', fg_mid2 = '#a89d94',
  accent = '#ffd3af', accent_bg = '#292522',
  azure_bg = '#004655'
}
-- stylua: ignore
local palette_b_fg = {
  blue = '#A3A9CE', cyan = '#89B3B6', green = '#85B695', red = '#D47766', yellow = '#EBC06D',
}
-- stylua: ignore
local palette_c = {
  blue = '#7F91B2', cyan = '#7B9695', green = '#78997A', red = '#BD8183', yellow = '#E49B5D',
}
-- stylua: ignore
local palette_d_bg = {
  blue_bg = '#273142', cyan_bg = '#253333', green_bg = '#233524', red_bg = '#7D2A2F', yellow_bg = '#8B7449',
}

-- No azure. Use blue
palette_b_fg.azure = palette_b_fg.blue
-- No orange. Use yellow
palette_b_fg.orange = palette_c.yellow
palette_d_bg.orange_bg = palette_d_bg.yellow_bg
-- No purple. MiniHues does not have magenta. Use melange magenta for purple
local magenta_b, magenta_c, magenta_d = '#CF9BC2', '#B380b0', '#422741'
palette_b_fg.purple = magenta_b
palette_d_bg.purple_bg = magenta_d

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local set = function()
  local p = require('mini.hues').get_palette()
  hi('Identifier', { fg = p.fg })
  hi('Function', { fg = p.yellow })
  hi('Operator', { fg = p.red })
  hi('Special', { fg = p.orange })
  hi('@constant.builtin', { fg = magenta_c })
  hi('@keyword', { fg = p.orange, bold = true })
  hi('@keyword.function', { fg = p.green })
  hi('@string', { fg = p.blue })
  hi('@string.escape', { fg = p.blue })
  hi('@string.regexp', { fg = p.blue })
  hi('@variable.parameter', { fg = p.fg })
  hi('@lsp.mod.defaultLibrary', { fg = p.yellow })
  hi('@lsp.type.builtinType', { fg = palette_c.cyan })
  hi('@lsp.type.event', { fg = palette_c.green })
  hi('@lsp.type.method', { fg = p.yellow })
  hi('@lsp.type.struct', { fg = p.green })
end
Config.new_autocmd('ColorScheme', 'minihues-melange', set, 'Hi for minihues-melange')

require('mini.hues').apply_palette(vim.tbl_deep_extend('force', generated, palette_d_bg, palette_b_fg))
vim.g.colors_name = 'minihues-melange'
