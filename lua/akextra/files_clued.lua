---@diagnostic disable: undefined-global
-- This 'extra' enables the bookmarks from mini.files to be shown mini.clue.
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

-- Copied from mini.files
local notify = function(msg, level_name) vim.notify('(FilesClued) ' .. msg, vim.log.levels[level_name]) end
local getcharstr = function()
  local ok, char = pcall(vim.fn.getcharstr)
  -- Terminate if couldn't get input (like with <C-c>) or on `<Esc>`
  if not ok or char == '' or char == '\3' or char == '\27' then return nil end
  return char
end
local fs_is_imaginary_path = function(path) return path:sub(-1) == '\000' end
local fs_is_present_path = function(path) return vim.loop.fs_stat(path) ~= nil and not fs_is_imaginary_path(path) end
local fs_get_type = function(path)
  if path == nil or not (not fs_is_imaginary_path(path) and fs_is_present_path(path)) then return nil end
  return vim.fn.isdirectory(path) == 1 and 'directory' or 'file'
end
-- See mini.files H.buffer.make_mappings, mark_goto. Changed: get state explorer state only once...
local open_bookmark = function()
  local id = getcharstr()
  if id == nil then return end

  local state = MiniFiles.get_explorer_state()
  local data = state.bookmarks[id]
  if data == nil then return notify('No bookmark with id ' .. vim.inspect(id), 'WARN') end

  local path = data.path
  if vim.is_callable(path) then path = path() end
  local is_valid_path = type(path) == 'string' and fs_get_type(vim.fn.expand(path)) == 'directory'
  if not is_valid_path then return notify('Bookmark path should be a valid path to directory', 'WARN') end

  MiniFiles.set_bookmark("'", state.branch[state.depth_focus], { desc = 'Before latest jump' })
  MiniFiles.set_branch({ path })
end
-- End copied from mini.files

-- Cache a copy of MiniClue global config
local miniclue_config_deepcopy = nil
-- MiniClue mark triggers
local clue_triggers = { { mode = { 'n', 'x' }, keys = "'" } }
-- Id of previous tabpage
local tab_prev = nil
-- Table with key: tabpage id, value: boolean(tab has active explorer)
local tabs = {}

local map_to_clue = function(id, b) return { mode = 'n', keys = "'" .. id, desc = b.desc } end
local get_clues = function()
  local state = MiniFiles.get_explorer_state()
  if state == nil then return {} end
  return vim.iter(pairs(state.bookmarks)):map(map_to_clue):totable()
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
  -- Clues, only for minifiles bookmarks
  get_global_config().clues = get_clues()
  -- Ensure global "'" mapping for minifiles bookmarks
  vim.keymap.set('n', "'", open_bookmark, { desc = 'MiniFiles open bookmark' })
end

local on_explorer_buffer_create = function(args)
  -- Remove the buffer local mapping minifiles created
  vim.keymap.del('n', 'm', { buf = args.data.buf_id })
  -- Activate clue with a restricted set of triggers
  local miniclue_config = get_global_config()
  miniclue_config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(args.data.buf_id)

  -- NOTE: Collect new bookmarks if explorer is active. There is no MiniFilesBookmarkAdded event...
  if tabs[vim.api.nvim_get_current_tabpage()] then miniclue_config.clues = get_clues() end
end

local on_explorer_open = function()
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
