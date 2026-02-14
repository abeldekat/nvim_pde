-- Not actively used...
-- Last commit: cf2a288696b03d0934da713d66c6d71557b5c997
-- Add to colors.txt: rose-pine

local prefer_light = require('ak.color').prefer_light

local info = {
  name = 'rose-pine',
  variants = { 'rose-pine-moon', 'rose-pine-main', 'rose-pine-dawn' },
}
Config.add_theme_info('rose-pine*', info, 'Rose-pine variants')

-- Before setup, the palette is set to main_nc:
local current_nc = '#16141f'

local hl_config = {
  -- MiniJump2dSpot = { fg = 'gold', bold = true, nocombine = true },
  -- MiniJump2dSpotAhead = { fg = 'gold', bold = true, nocombine = true },
  -- MiniJump2dSpotUnique = { fg = 'gold', bold = true, nocombine = true },

  -- Area for messages and cmdline
  MsgArea = { fg = 'muted', current = current_nc },
}

--          ╭─────────────────────────────────────────────────────────╮
--          │               functions for highlighting                │
--          │            see lualine.themes.rose-pine.lua             │
--          ╰─────────────────────────────────────────────────────────╯

local function apply_hl(highlight, palette, copy_from)
  highlight.bg = palette[copy_from.bg]
  highlight.fg = palette[copy_from.fg]
  highlight.bold = copy_from.bold
  return highlight
end

-- create initial modified hl
local function groups()
  local palette = require('rose-pine.palette')
  local result = {}
  for name, copy_from in pairs(hl_config) do -- use palette for actual colors
    result[name] = apply_hl({}, palette, copy_from)
  end
  return result
end

-- change hl when palette changes
local function before_highlight(group, highlight, palette)
  local copy_from = hl_config[group]
  if copy_from and copy_from.current ~= palette._nc then
    apply_hl(highlight, palette, copy_from)
    copy_from.current = palette._nc
  end
end

vim.o.background = prefer_light and 'light' or 'dark'
local opts = {
  variant = prefer_light and 'dawn' or 'main',

  disable_italics = true,
  highlight_groups = groups(),
  before_highlight = before_highlight,
}
require('rose-pine').setup(opts)
