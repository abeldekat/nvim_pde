---@diagnostic disable: undefined-global
-- This 'extra' makes it possible to show bookmarks and g mappings from MiniFiles in MiniClue
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519
-- Prerequisites: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- The description of global 'g' mappings changes when the explorer is open,
-- because the mappings cannot be removed from the clues window in a reasonable way
-- Example usage:
--[[
   require('mini.files').setup()
  -- .. add bookmarks and 'g' mappings, see `:h MiniFiles-examples`
  require('mini.clue').setup()
  -- .. setup other plugins that have global 'g' mappings
  require('<this_file>').setup()
--]]

-- MiniClue triggers for MiniFiles
local clue_triggers = { { mode = { 'n' }, keys = "'" }, { mode = { 'n' }, keys = 'g' } }
-- The description of a global 'g' mapping when explorer, for better 'clues' readability
local g_dummy_description = '***'
-- Flag indicating that 'g' mappings have been modified
local g_has_been_modified = false
-- Cache. List with the dictionaries of the original global 'g' mappings
local g_originals = {}
-- Cache. List with the dictionaries of the modified global 'g' mappings
local g_modified = {}
-- Cache. A copy of MiniClue's global config
local miniclue_config_deepcopy = nil
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(true if tab has open explorer)
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

local mapset_global_g = function(g_dictionaries, is_modified)
  local is_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
  vim.iter(ipairs(g_dictionaries)):filter(is_present):each(function(_, m) vim.fn.mapset(m) end)
  g_has_been_modified = is_modified
end

local restore_globally = function()
  -- Restore the global MiniClue config
  MiniClue.config = miniclue_config_deepcopy
  -- Ensure a fresh deepcopy on next override
  miniclue_config_deepcopy = nil
  -- Remove the global 'open bookmark' mapping for MiniFiles
  vim.keymap.del('n', "'")
  -- Restore the descriptions of the global 'g' mappings
  if g_has_been_modified then mapset_global_g(g_originals, false) end
end

local bm_to_clue = function(id, b) return { mode = 'n', keys = "'" .. id, desc = b.desc } end
local override_globally = function()
  -- Never show the original config clues
  get_config_override().clues = {}
  -- Early return
  local state = MiniFiles.get_explorer_state()
  if not (state and mark_goto_rhs) then return end

  -- Change the description of global 'g' mappings
  if not g_has_been_modified then mapset_global_g(g_modified, true) end
  -- Override 'config clues' to only contain bookmarks from MiniFiles
  get_config_override().clues = vim.iter(pairs(state.bookmarks)):map(bm_to_clue):totable()
  -- Ensure global "'" mapping for MiniFiles
  vim.keymap.set('n', "'", mark_goto_rhs, { desc = 'MiniFiles open bookmark' })
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

  -- The "'" mapping must be from MiniFiles, as MiniClue is not yet enabled on explorer's buffers
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

local handle_already_opened_explorers = function()
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function() explorer_open() end)
end

local build_g_cache = function()
  g_originals, g_modified = {}, {}
  local g_only = function(_, info) return info.lhs:sub(1, 1) == 'g' end
  vim.iter(ipairs(vim.api.nvim_get_keymap('n'))):filter(g_only):each(function(_, mapping_info)
    table.insert(g_originals, vim.deepcopy(mapping_info))
    mapping_info.desc = g_dummy_description
    table.insert(g_modified, mapping_info)
  end)
end

local FilesClued = {}
FilesClued.setup = function()
  if MiniFiles == nil or MiniClue == nil then return end
  if MiniFiles.config.mappings.mark_goto ~= "'" then return end
  _G.FilesClued = FilesClued

  build_g_cache()
  handle_already_opened_explorers()
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
