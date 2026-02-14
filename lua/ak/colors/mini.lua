local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end

--          ╭─────────────────────────────────────────────────────────╮
--          │                         base16                          │
--          ╰─────────────────────────────────────────────────────────╯
local base16_variants = { 'minischeme', 'minicyan' }
local base16_info = {
  name = 'mini_base16',
  variants = base16_variants,
}
Config.add_theme_info(base16_variants, base16_info, 'Mini base16 variants')

Config.new_autocmd('ColorScheme', base16_variants, function()
  local p = MiniBase16.config.palette
  if p == nil then return end

  -- Is a link to DiagnosticFloatingHint, change to bold orange
  hi('MiniPickMatchRanges', { fg = 'orange', bold = true })
  -- Area for messages and cmdline, change p.base05
  hi('MsgArea', { fg = p.base03 })
end, 'Mini base16 on colorscheme')

--          ╭─────────────────────────────────────────────────────────╮
--          │                          hues                           │
--          ╰─────────────────────────────────────────────────────────╯
local hues_variants = { 'miniwinter', 'minispring', 'minisummer', 'miniautumn' }
local hues_info = {
  name = 'mini_seasons',
  variants = hues_variants,
}
Config.add_theme_info(hues_variants, hues_info, 'Mini hues season variants')

local randomhue = 'randomhue'
local randomhue_info = { -- toggle randoms
  name = 'mini_randomhue',
  variants = { randomhue },
}
Config.add_theme_info(randomhue, randomhue_info, 'Mini randomhue variants')

local all_hues_variants = { randomhue }
vim.list_extend(all_hues_variants, hues_variants)
Config.new_autocmd('ColorScheme', all_hues_variants, function()
  local p = require('mini.hues').get_palette()

  hi('MiniJump2dSpot', { fg = p.orange, bg = nil, bold = true, nocombine = true }) -- yellow
  -- hi('MiniJump2dSpotAhead', { link = 'MiniJump2dSpot' })
  -- hi('MiniJump2dSpotUnique', { link = 'MiniJump2dSpot' })

  -- Is a link to DiagnosticFloatingHint, change to bold orange:
  hi('MiniPickMatchRanges', { fg = p.orange, bold = true })
  -- Area for messages and cmdline, changed from Normal to Comment.fg
  hi('MsgArea', { fg = p.fg_mid2 })
end, 'Mini hues on colorscheme')
