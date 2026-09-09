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

-- Next theme variant -> another builtin
local builtin = { 'minischeme2', 'minispring', 'minisummer', 'miniautumn', 'miniwinter' }
Config.add_theme_info(builtin, { name = 'mini_builtin', variants = builtin }, 'Mini hues variants')

-- Next theme variant -> another custom
local my = { 'miniayu', 'minibamboo', 'minimelange', 'minirosepine' }
Config.add_theme_info(my, { name = 'my_variants', variants = my }, 'My hues variants')

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end
local all_hues_variants = vim.iter({ randoms, builtin, my }):flatten(1):totable()
Config.new_autocmd('ColorScheme', all_hues_variants, function()
  local p = hues.get_palette()

  hi('MiniJump2dSpot', { fg = p.orange, bg = nil, bold = true, nocombine = true })
  -- Is a link to DiagnosticFloatingHint, change to bold orange:
  hi('MiniPickMatchRanges', { fg = p.orange, bold = true })
  -- Area for messages and cmdline, changed from Normal to Comment.fg
  hi('MsgArea', { fg = p.fg_mid2 })
end, 'Mini hues on colorscheme')
