---@diagnostic disable: undefined-global
local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'

local hi = function(name, data) vim.api.nvim_set_hl(0, name, data) end

local base16 = require('mini.base16')

-- Restrict number of supported plugins
local restrict_plugins = { plugins = { default = false, ['nvim-mini/mini.nvim'] = true } }
local setup_base16 = base16.setup
base16.setup = function(config) setup_base16(vim.tbl_deep_extend('force', config or {}, restrict_plugins)) end

local variants = { 'minischeme', 'minicyan' }
Config.add_theme_info(variants, { name = 'mini_base16', variants = variants }, 'Mini base16 variants')

Config.new_autocmd('ColorScheme', variants, function()
  local p = MiniBase16.config.palette
  if p == nil then return end

  -- Statuscolumn: Change bg from base01 to base00
  hi('CursorLineFold', { fg = p.base0C, bg = p.base00 })
  hi('CursorLineNr', { fg = p.base04, bg = p.base00 })
  hi('CursorLineSign', { fg = p.base03, bg = p.base00 })
  hi('FoldColumn', { fg = p.base0C, bg = p.base00 })
  hi('LineNr', { fg = p.base03, bg = p.base00 })
  hi('LineNrAbove', { fg = p.base03, bg = p.base00 })
  hi('LineNrBelow', { fg = p.base03, bg = p.base00 })
  hi('SignColumn', { fg = p.base03, bg = p.base00 })
  hi('MiniDiffSignAdd', { fg = p.base0B, bg = p.base00 })
  hi('MiniDiffSignChange', { fg = p.base0E, bg = p.base00 })
  hi('MiniDiffSignDelete', { fg = p.base08, bg = p.base00 })
  hi('DiagnosticSignError', { fg = p.base08, bg = p.base00 })
  hi('DiagnosticSignHint', { fg = p.base0D, bg = p.base00 })
  hi('DiagnosticSignInfo', { fg = p.base0C, bg = p.base00 })
  hi('DiagnosticSignOk', { fg = p.base0B, bg = p.base00 })
  hi('DiagnosticSignWarn', { fg = p.base0E, bg = p.base00 })

  -- Avoid bg=base01 by linking explicitly to the new LineNr hl.
  -- It will be overwritten by the calculated 'dim' from MiniStatuscolumn
  -- if its setup runs *after* the code in this module.
  hi('MiniStatuscolumnDim', { link = 'LineNr' })

  -- Also need to change NormalFloat because of statuscolumn change:
  hi('NormalFloat', { fg = p.base05, bg = p.base00 })
  -- Is a link to DiagnosticFloatingHint, change to bold orange:
  hi('MiniPickMatchRanges', { fg = p.orange, bold = true })
  -- Area for messages and cmdline, change p.base05
  hi('MsgArea', { fg = p.base03 })
end, 'Mini base16 on colorscheme')
