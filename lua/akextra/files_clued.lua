---@diagnostic disable: undefined-global
-- This 'extra' makes it possible to show bookmarks and g mappings from MiniFiles in MiniClue
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519
-- Prerequisites: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- Example usage:
--[[
   require('mini.files').setup()
  -- .. add bookmarks and 'g' mappings, see `:h MiniFiles-examples`
  require('mini.clue').setup()
  -- .. setup other plugins that have 'g' mappings not needed in MiniFiles
  require('<this_file>').setup()
--]]

-- MiniClue triggers for MiniFiles: open bookmarks and g key
local mark_goto = "'"
local clue_triggers = { { mode = { 'n' }, keys = mark_goto }, { mode = { 'n' }, keys = 'g' } }
-- The 'g' clues contain global mappings not needed in MiniFiles. See MiniClue H.clues_get_all
-- stylua: ignore
local g_to_delete = {
  'ga', 'gA', 'gc', 'gcc', 'gh', 'gH', 'go', 'gO', 'gS', 'gV', 'g%', 'g=', 'g==', 'g[', 'g]'
}
-- List with the dictionaries of the deleted mappings so they can be restored
local g_to_restore = nil
-- Cache a copy of MiniClue global config
local miniclue_config_deepcopy = nil
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(true if tab has active explorer)
local tabs = {}
-- A reference to the mark_goto function in MiniFiles. See its H.buffer_make_mappings
local mark_goto_rhs = nil

local get_config_override = function()
  if miniclue_config_deepcopy == nil then miniclue_config_deepcopy = vim.deepcopy(MiniClue.config) end
  return MiniClue.config
end

local explorer_is_open = function(tabpage)
  if tabpage == nil then tabpage = vim.api.nvim_get_current_tabpage() end
  return tabs[tabpage]
end
local explorer_set_open = function(is_open) tabs[vim.api.nvim_get_current_tabpage()] = is_open end

local restore_globally = function()
  -- Restore the global MiniClue config
  MiniClue.config = miniclue_config_deepcopy
  -- Ensure a fresh deepcopy on next override
  miniclue_config_deepcopy = nil
  -- Remove the global open bookmark mapping
  vim.keymap.del('n', "'")
  -- Restore global g mappings which were deleted when explorer opened
  if g_to_restore ~= nil then vim.iter(ipairs(g_to_restore)):each(function(_, m) vim.fn.mapset(m) end) end
  g_to_restore = nil
end

local delete_g_mappings = function()
  -- Bind global next to local next for performance...
  local next = next
  local to_mapping_info = function(_, lhs) return vim.fn.maparg(lhs, 'n', false, true) end
  local not_empty = function(mapping_info) return next(mapping_info) ~= nil end
  local restore = {}
  vim.iter(ipairs(g_to_delete)):map(to_mapping_info):filter(not_empty):each(function(mapping_info)
    table.insert(restore, mapping_info)
    vim.keymap.del('n', mapping_info.lhs)
  end)
  return restore
end
local bookmark_to_clue = function(id, b) return { mode = 'n', keys = mark_goto .. id, desc = b.desc } end
local override_globally = function()
  -- Never show the original config clues
  get_config_override().clues = {}
  -- Early return
  local state = MiniFiles.get_explorer_state()
  if not (state and mark_goto_rhs) then return end

  -- Override 'config clues' to only contain bookmarks from MiniFiles
  get_config_override().clues = vim.iter(pairs(state.bookmarks)):map(bookmark_to_clue):totable()
  -- Ensure global "'" mapping to local "mark_goto" handler in MiniFiles
  vim.keymap.set('n', mark_goto, mark_goto_rhs, { desc = 'MiniFiles open bookmark' })
  -- Delete global mappings that are not needed in MiniFiles
  g_to_restore = g_to_restore == nil and delete_g_mappings() or g_to_restore
end

local enable = function(buf_id)
  -- Activate MiniClue with a restricted set of triggers
  local miniclue_config = get_config_override()
  miniclue_config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
end

local explorer_buffer_create = function(args)
  if not explorer_is_open() then return end

  enable(args.data.buf_id)
  -- NOTE: Update bookmarks. There is no MiniFilesBookmarkAdded event...
  override_globally()
end

local explorer_open = function()
  if explorer_is_open() then return end

  -- MiniClue is not yet enabled on explorer's buffers. The "'" mapping must be from MiniFiles
  if mark_goto_rhs == nil then mark_goto_rhs = vim.fn.maparg("'", 'n', false, true).callback end
  -- Enable MiniClue in all buffers
  local state = MiniFiles.get_explorer_state()
  vim.iter(ipairs(state.windows)):each(function(_, w) enable(vim.api.nvim_win_get_buf(w.win_id)) end)
  override_globally()
  explorer_set_open(true)
end

local explorer_close = function()
  if not explorer_is_open() then return end

  restore_globally()
  explorer_set_open(false)
end

local buf_enter = function()
  if tab_prev == nil then tab_prev = vim.api.nvim_get_current_tabpage() end
  local tab_current = vim.api.nvim_get_current_tabpage()
  if tab_prev == tab_current then return end

  if explorer_is_open(tab_prev) then restore_globally() end
  if explorer_is_open(tab_current) then override_globally() end
  tab_prev = tab_current
end

local FilesClued = {}
FilesClued.setup = function()
  -- Early returns
  if MiniFiles == nil or MiniClue == nil then return end
  if MiniFiles.config.mappings.mark_goto ~= mark_goto then return end
  _G.FilesClued = FilesClued

  -- Handle explorers that are already open
  local b = vim.tbl_filter(vim.api.nvim_buf_is_loaded, vim.api.nvim_list_bufs())
  b = vim.tbl_filter(function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end, b)
  vim.iter(ipairs(b)):each(function() explorer_open() end)

  -- Setup autocommands
  local augroup = vim.api.nvim_create_augroup('FilesClued', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('BufEnter', '*', buf_enter, 'Administer MiniClue per tabpage')
  au('User', 'MiniFilesBufferCreate', explorer_buffer_create, 'Show MiniFiles in MiniClue')
  au('User', 'MiniFilesExplorerOpen', explorer_open, 'Show MiniFiles in MiniClue')
  au('User', 'MiniFilesExplorerClose', explorer_close, 'Restore regular MiniClue')
end
return FilesClued
