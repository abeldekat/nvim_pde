---@diagnostic disable: undefined-global
-- This 'extra' makes it possible to show the bookmarks from mini.files in mini.clue.
-- General idea: Recreate bookmark "'" mapping, but global. Manipulate MiniClue.config.
-- See discussions:
-- https://github.com/nvim-mini/mini.nvim/discussions/2454
-- https://github.com/nvim-mini/mini.nvim/discussions/1195
-- Prerequisites: MiniFiles and MiniClue active.
-- Example usage:
--[[
   require('mini.files').setup()
  -- add bookmarks, see `:h MiniFiles-examples`
  require('mini.clue').setup()
  require('<this_file>').setup()
--]]

-- Cache a copy of MiniClue global config
local miniclue_config_deepcopy = nil
-- MiniClue triggers for MiniFiles: bookmarks
local clue_triggers = { { mode = { 'n' }, keys = "'" } }
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(tab has active explorer)
local tabs = {}
-- A reference to the mark_goto function in MiniFiles. See its H.buffer_make_mappings.
local mark_goto_cb = nil

local bookmark_to_clue = function(id, b) return { mode = 'n', keys = "'" .. id, desc = b.desc } end
local get_files_clues = function()
  local state = MiniFiles.get_explorer_state()
  if state == nil then return {} end
  return vim.iter(pairs(state.bookmarks)):map(bookmark_to_clue):totable()
end

local get_global_config = function()
  if miniclue_config_deepcopy == nil then miniclue_config_deepcopy = vim.deepcopy(MiniClue.config) end
  return MiniClue.config
end

local restore = function()
  -- Restore the global miniclue config
  MiniClue.config = miniclue_config_deepcopy
  miniclue_config_deepcopy = nil
  -- Remove the global mapping
  vim.keymap.del('n', "'")
end

local override = function()
  -- Clues, only for minifiles
  get_global_config().clues = get_files_clues()
  if not mark_goto_cb then return end

  -- Ensure global "'" mapping for minifiles bookmarks
  vim.keymap.set('n', "'", mark_goto_cb, { desc = 'MiniFiles open bookmark' })
end

local enable = function(buf_id)
  -- Activate clue with a restricted set of triggers
  local miniclue_config = get_global_config()
  miniclue_config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
end

local on_explorer_buffer_create = function(args)
  -- If explorer is not yet open, enable buffer later
  if not tabs[vim.api.nvim_get_current_tabpage()] then return end

  -- Explorer is open, enable buffer here
  enable(args.data.buf_id)
  -- NOTE: Update bookmarks if explorer is active. There is no MiniFilesBookmarkAdded event...
  override()
end

local on_explorer_open = function()
  -- MiniClue is not yet enabled on explorer's buffers. Thus, the "'" mapping is from MiniFiles
  if mark_goto_cb == nil then mark_goto_cb = vim.fn.maparg("'", 'n', false, true).callback end

  -- Enable mini.clue in all buffers
  local state = MiniFiles.get_explorer_state()
  vim.iter(ipairs(state.windows)):each(function(_, w) enable(vim.api.nvim_win_get_buf(w.win_id)) end)
  override()
  tabs[vim.api.nvim_get_current_tabpage()] = true
end

local on_explorer_close = function()
  restore()
  tabs[vim.api.nvim_get_current_tabpage()] = false
end

local on_buf_enter = function()
  if tab_prev == nil then tab_prev = vim.api.nvim_get_current_tabpage() end
  local tab_current = vim.api.nvim_get_current_tabpage()
  if tab_prev == tab_current then return end

  local has_explorer = tabs[tab_prev] == true
  if has_explorer then restore() end
  has_explorer = tabs[tab_current] == true
  if has_explorer then override() end

  tab_prev = tab_current
end

local FilesClued = {}
FilesClued.setup = function()
  if MiniFiles == nil or MiniClue == nil then return end
  _G.FilesClued = FilesClued

  local augroup = vim.api.nvim_create_augroup('FilesClued', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('BufEnter', '*', on_buf_enter, 'Ensure correct miniclue config per tabpage')
  au('User', 'MiniFilesBufferCreate', on_explorer_buffer_create, 'Enable clues for mini.files')
  au('User', 'MiniFilesExplorerOpen', on_explorer_open, 'Use mini.files in clues')
  au('User', 'MiniFilesExplorerClose', on_explorer_close, 'Restore regular clues')
end
return FilesClued
