---@diagnostic disable: undefined-global
local group_default_hl = 'MiniStatuslineDevinfo' -- not using MiniStatuslineFileInfo
local ignored_ft = { ministarter = true, minifiles = true, minipick = true }

-- Overridden: Return early when ft should not be displayed because of laststatus=3
local section_filename = function(...)
  if ignored_ft[vim.bo.filetype] then return '' end
  return MiniStatusline.section_filename(...)
end

-- Overridden: Removed filesize. Encoding and format are optional
local section_fileinfo = function(args)
  local filetype = vim.bo.filetype
  local icon = MiniIcons and filetype ~= '' and MiniIcons.get('filetype', filetype)
  filetype = icon and icon or filetype -- either show icon or text

  if MiniStatusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= '' then return filetype end

  local encoding, format = vim.bo.fileencoding or vim.bo.encoding, vim.bo.fileformat
  local info = ''
  if not (encoding == 'utf-8' and format == 'unix') then info = string.format(' %s[%s]', encoding, format) end

  return string.format('%s%s', filetype, info)
end

local section_tabinfo = function(args)
  if MiniStatusline.is_truncated(args.trunc_width) then return '' end
  local tabnr = vim.api.nvim_tabpage_get_number(0)
  if tabnr == 1 then return '' end
  return string.format('t%d', tabnr)
end

local section_macro = function(args)
  if MiniStatusline.is_truncated(args.trunc_width) then return '' end
  local reg = vim.fn.reg_recording()
  return reg == '' and '' or 'REC @' .. reg
end

local active = function()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  mode = string.find(mode, 'N', 1, false) and 'N' or mode

  local git = MiniStatusline.section_git({ trunc_width = 40 })
  local diff = MiniStatusline.section_diff({ trunc_width = 75, icon = '' })
  local diag = MiniStatusline.section_diagnostics({ trunc_width = 75, icon = '' })
  local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })

  local filename = section_filename({ trunc_width = 140 })

  local macro = section_macro({ trunc_width = 40 })
  local tabinfo = section_tabinfo({ trunc_width = 40 })

  local fileinfo = section_fileinfo({ trunc_width = 120 })
  local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
  local location = MiniStatusline.section_location({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl, strings = { mode } },
    { hl = group_default_hl, strings = { git, diff, diag, lsp } },
    '%<',
    { hl = 'MiniStatuslineFilename', strings = { filename } },
    '%=',
    { hl = 'MiniHipatternsHack', strings = { macro, tabinfo } },
    { hl = group_default_hl, strings = { fileinfo } },
    { hl = mode_hl, strings = { search, location } },
  })
end

require('mini.statusline').setup({ content = { active = active } })
local override_normal_hl = function() vim.api.nvim_set_hl(0, 'MiniStatuslineModeNormal', { link = group_default_hl }) end
override_normal_hl()
Config.new_autocmd('ColorScheme', '*', override_normal_hl, 'Override MiniStatuslineModeNormal')
