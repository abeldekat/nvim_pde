---@diagnostic disable: undefined-global
-- -- This 'extra' makes it possible to show bookmarks and g mappings from mini.files in mini.clue.
-- This 'extra' makes it possible to show bookmarks from mini.files in mini.clue.
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
-- -- MiniClue triggers for MiniFiles: open bookmarks and g key(by remapping to '`')
-- local clue_triggers = { { mode = { 'n' }, keys = "'" }, { mode = { 'n' }, keys = '`' } }
-- MiniClue triggers for MiniFiles: open bookmarks
local clue_triggers = { { mode = { 'n' }, keys = "'" } }
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(true if tab has active explorer)
local tabs = {}
-- A reference to the mark_goto function in MiniFiles. See its H.buffer_make_mappings.
local mark_goto_rhs = nil

local bookmark_to_clue = function(id, b) return { mode = 'n', keys = "'" .. id, desc = b.desc } end
local get_bookmark_clues = function()
  -- Order of clue precedence: config clues < global mappings < buffer mappings
  local state = MiniFiles.get_explorer_state()
  return state and vim.iter(pairs(state.bookmarks)):map(bookmark_to_clue):totable() or {}
end

local get_global_config = function()
  if miniclue_config_deepcopy == nil then miniclue_config_deepcopy = vim.deepcopy(MiniClue.config) end
  return MiniClue.config
end

local restore = function()
  -- Restore the global miniclue config
  MiniClue.config = miniclue_config_deepcopy
  miniclue_config_deepcopy = nil
  -- Remove the global open bookmark mapping
  vim.keymap.del('n', "'")
end

local override = function()
  -- Override 'config clues' to only contain minifiles bookmarks
  get_global_config().clues = get_bookmark_clues()

  -- Ensure global "'" mapping for minifiles bookmarks
  if not mark_goto_rhs then return end
  vim.keymap.set('n', "'", mark_goto_rhs, { desc = 'MiniFiles open bookmark' })
end

local enable = function(buf_id)
  -- Activate miniclue with a restricted set of triggers
  local miniclue_config = get_global_config()
  miniclue_config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
end

local explorer_is_open = function(tabpage)
  if tabpage == nil then tabpage = vim.api.nvim_get_current_tabpage() end
  return tabs[tabpage]
end
local explorer_set_open = function(is_open) tabs[vim.api.nvim_get_current_tabpage()] = is_open end

local explorer_buffer_create = function(args)
  -- If explorer is not yet open, enable buffer later
  if not explorer_is_open() then return end

  -- Explorer is open, enable buffer here
  enable(args.data.buf_id)
  -- NOTE: Update bookmarks. There is no MiniFilesBookmarkAdded event...
  override()
end

local explorer_open = function()
  -- MiniClue is not yet enabled on explorer's buffers. The "'" mapping must be from MiniFiles
  if mark_goto_rhs == nil then mark_goto_rhs = vim.fn.maparg("'", 'n', false, true).callback end

  -- Enable mini.clue in all buffers
  local state = MiniFiles.get_explorer_state()
  vim.iter(ipairs(state.windows)):each(function(_, w) enable(vim.api.nvim_win_get_buf(w.win_id)) end)
  override()
  explorer_set_open(true)
end

local explorer_close = function()
  restore()
  explorer_set_open(false)
end

local buf_enter = function()
  if tab_prev == nil then tab_prev = vim.api.nvim_get_current_tabpage() end
  local tab_current = vim.api.nvim_get_current_tabpage()
  if tab_prev == tab_current then return end

  if explorer_is_open(tab_prev) then restore() end
  if explorer_is_open(tab_current) then override() end
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
  au('BufEnter', '*', buf_enter, 'Ensure correct miniclue config per tabpage')
  au('User', 'MiniFilesBufferCreate', explorer_buffer_create, 'Use mini.files in clues')
  au('User', 'MiniFilesExplorerOpen', explorer_open, 'Use mini.files in clues')
  au('User', 'MiniFilesExplorerClose', explorer_close, 'Restore regular clues')
end
return FilesClued
