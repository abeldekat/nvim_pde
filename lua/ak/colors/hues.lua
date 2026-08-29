---@diagnostic disable: undefined-global
local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local hues = require('mini.hues')

-- Restrict number of supported plugins via setup(ie randomhue)
local restrict_plugins = { plugins = { default = false, ['nvim-mini/mini.nvim'] = true } }
local setup_hues = hues.setup
hues.setup = function(config) setup_hues(vim.tbl_deep_extend('force', config or {}, restrict_plugins)) end
-- Restrict number of supported plugins via direct 'apply_palette' call(ie miniwinter)
hues.config.plugins = restrict_plugins.plugins

-- Next theme variant -> another random
local randoms = { 'randomhue' }
Config.add_theme_info(randoms, { name = 'mini_randomhue', variants = randoms }, 'Mini randomhue variants')

-- Next theme variant -> another season
local seasons = { 'miniwinter', 'minispring', 'minisummer', 'miniautumn' }
Config.add_theme_info(seasons, { name = 'mini_seasons', variants = seasons }, 'Mini hues season variants')

-- Next theme variant -> another custom
local ak = { 'miniayu', 'minibamboo', 'minimelange' }
Config.add_theme_info(ak, { name = 'my_variants', variants = ak }, 'Ak hues variants')

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local all_hues_variants = vim.iter({ randoms, seasons, ak }):flatten(1):totable()
Config.new_autocmd('ColorScheme', all_hues_variants, function()
  local p = hues.get_palette()

  hi('MiniJump2dSpot', { fg = p.orange, bg = nil, bold = true, nocombine = true }) -- yellow
  -- Is a link to DiagnosticFloatingHint, change to bold orange:
  hi('MiniPickMatchRanges', { fg = p.orange, bold = true })
  -- Area for messages and cmdline, changed from Normal to Comment.fg
  hi('MsgArea', { fg = p.fg_mid2 })
end, 'Mini hues on colorscheme')
