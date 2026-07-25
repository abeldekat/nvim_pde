---@diagnostic disable: undefined-global
-- This 'extra' makes it possible to show bookmarks and g mappings from MiniFiles in MiniClue
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519
-- Prerequisites: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- Example usage:
--[[
   require('mini.files').setup()
  -- add bookmarks and 'g' mappings, see `:h MiniFiles-examples`.
  require('mini.clue').setup()
  require('<this_file>').setup()
--]]

-- MiniClue triggers for MiniFiles: open bookmarks and g key
local mark_goto = "'"
local clue_triggers = { { mode = { 'n' }, keys = mark_goto }, { mode = { 'n' }, keys = 'g' } }
-- Cache a copy of MiniClue global config
local miniclue_config_deepcopy = nil
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(true if tab has active explorer)
local tabs = {}
-- A reference to the mark_goto function in MiniFiles. See its H.buffer_make_mappings
local mark_goto_rhs = nil
-- The 'g' clues contain global mappings not specific to MiniFiles. See MiniClue, its H.clues_get_all
local nvim_get_keymap = vim.api.nvim_get_keymap

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
  vim.api.nvim_get_keymap = nvim_get_keymap
  -- Restore the global MiniClue config
  MiniClue.config = miniclue_config_deepcopy
  -- Ensure a fresh deepcopy on next override
  miniclue_config_deepcopy = nil
  -- Remove the global open bookmark mapping
  vim.keymap.del('n', "'")
end

local bookmark_to_clue = function(id, b) return { mode = 'n', keys = mark_goto .. id, desc = b.desc } end
local override_globally = function()
  -- Never show the original config clues
  get_config_override().clues = {}
  -- Return early
  local state = MiniFiles.get_explorer_state()
  if not (state and mark_goto_rhs) then return end

  -- HACK: Manipulate nvim_get_keymap in order to only include 'g' clues from MiniFiles
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.api.nvim_get_keymap = function(mode)
    if mode == 'n' and explorer_is_open() then return {} end
    return nvim_get_keymap(mode)
  end

  -- Override 'config clues' to only contain bookmarks from MiniFiles
  get_config_override().clues = vim.iter(pairs(state.bookmarks)):map(bookmark_to_clue):totable()

  -- Ensure global "'" mapping to local "mark_goto" handler in minifiles
  vim.keymap.set('n', mark_goto, mark_goto_rhs, { desc = 'MiniFiles open bookmark' })
end

local enable = function(buf_id)
  -- Activate MiniClue with only the restricted set of triggers
  local miniclue_config = get_config_override()
  miniclue_config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
end

local explorer_buffer_create = function(args)
  -- If explorer is not yet open, enable buffer later
  if not explorer_is_open() then return end

  -- Explorer is open, enable buffer here
  enable(args.data.buf_id)
  -- NOTE: Update bookmarks. There is no MiniFilesBookmarkAdded event...
  override_globally()
end

local explorer_open = function()
  -- MiniClue is not yet enabled on explorer's buffers. The "'" mapping must be from MiniFiles
  if mark_goto_rhs == nil then mark_goto_rhs = vim.fn.maparg("'", 'n', false, true).callback end

  -- Enable MiniClue in all buffers
  local state = MiniFiles.get_explorer_state()
  vim.iter(ipairs(state.windows)):each(function(_, w) enable(vim.api.nvim_win_get_buf(w.win_id)) end)
  override_globally()
  explorer_set_open(true)
end

local explorer_close = function()
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
  if MiniFiles == nil or MiniClue == nil then return end
  if MiniFiles.config.mappings.mark_goto ~= mark_goto then return end
  _G.FilesClued = FilesClued

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
