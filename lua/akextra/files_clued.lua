---@diagnostic disable: undefined-global, inject-field
-- This 'extra' enables showing bookmarks and 'g' mappings from MiniFiles with MiniClue
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519
-- Prerequisites: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
--
-- The descriptions of *global* 'g' mappings change temporarily when the explorer is open and
-- user presses 'g'. This workaround is needed because MiniClue always includes all mappings
--
-- Example usage:
--[[
   require('mini.files').setup()
  -- .. add bookmarks and 'g' mappings, see `:h MiniFiles-examples`
  require('mini.clue').setup()
  -- .. setup other plugins that have global 'g' mappings
  require('<this_file>').setup()
--]]

-- The triggers used when explorer is open
local clue_triggers = { { mode = { 'n' }, keys = "'" }, { mode = { 'n' }, keys = 'g' } }
-- The description of a global 'g' mapping in open explorer, for better 'clues' readability
local g_dummy_description = '***'
-- Flag indicating that the descriptions of the global 'g' mappings have been modified
local g_descriptions_are_modified = false
-- Cache. List with the dictionaries of the original global 'g' mappings
local g_originals = {}
-- Cache. List with the dictionaries of the global 'g' mappings with modified descriptions
local g_modified = {}
-- Cache: Deepcopy of global MiniClue config
local miniclue_config_deepcopy

-- Copied from MiniFiles in order to write a local "mark_goto"
local notify = function(msg, level_name) vim.notify('(FilesClued) ' .. msg, vim.log.levels[level_name]) end
local fs_is_imaginary_path = function(path) return path:sub(-1) == '\000' end
local fs_is_present_path = function(path) return vim.loop.fs_stat(path) ~= nil and not fs_is_imaginary_path(path) end
local fs_get_type = function(path)
  if path == nil or not (not fs_is_imaginary_path(path) and fs_is_present_path(path)) then return nil end
  return vim.fn.isdirectory(path) == 1 and 'directory' or 'file'
end
-- End copied from MiniFiles

-- MiniFiles->H.buffer_make_mappings->mark_goto uses its 'H.getcharstr' to obtain the id
-- FilesClued creates a buffer mapping from each bookmark, so mark_goto has to be changed slightly
local mark_goto = function(id)
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
local add_mark_mappings = function(buf_id)
  local state = MiniFiles.get_explorer_state()
  vim.iter(pairs(state.bookmarks)):each(function(id, bookmark)
    local opts = { buf = buf_id, desc = bookmark.desc }
    vim.keymap.set('n', "'" .. id, function() mark_goto(id) end, opts)
  end)
end

local override_g_globally = function(g_dictionaries, is_override)
  local still_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
  vim.iter(ipairs(g_dictionaries)):filter(still_present):each(function(_, m) vim.fn.mapset(m) end)
  g_descriptions_are_modified = is_override
end

local map_trigger = function(trigger, buf_id, rhs)
  -- See MiniClue->H.map_trigger
  local opts = { nowait = true, buf = buf_id, desc = 'FilesClued for ' .. trigger }
  vim.keymap.set('n', trigger, rhs, opts)
end
local decorate_miniclue_trigger = function(trigger_char, buf_id, cb_before_trigger, cb_after_trigger)
  local miniclue_mapping_info = vim.fn.maparg(trigger_char, 'n', false, true)
  if miniclue_mapping_info.buffer ~= 1 then return end

  local decorated_callback
  decorated_callback = function()
    local clues_orig = MiniClue.config.clues

    -- During this invocation of 'trigger-char', don't show global 'config clues'
    MiniClue.config.clues = {}
    -- Perform any necessary action to enable MiniClue to show the expected clues
    cb_before_trigger()
    -- Execute the MiniClue trigger
    miniclue_mapping_info.callback()
    -- If needed, undo the actions from 'cb_before_trigger'
    if cb_after_trigger then cb_after_trigger() end
    -- Restore the global "config clues"
    MiniClue.config.clues = clues_orig

    -- MiniClue unmaps on exec and schedules the mapping to be recreated. See MiniClue, H.state_exec
    vim.schedule(function() map_trigger(trigger_char, buf_id, decorated_callback) end)
  end
  map_trigger(trigger_char, buf_id, decorated_callback)
end

local attach = function(buf_id)
  -- Triggers: Restricted to "'" and 'g'
  -- Solution from discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  MiniClue.config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Decorate triggers to manipulate the clues shown when explorer is open
  -- Important: Calls must be scheduled!
  vim.schedule(function()
    -- Ensure that bookmarks created when inside explorer are also included
    local cb_before = function() add_mark_mappings(buf_id) end
    decorate_miniclue_trigger("'", buf_id, cb_before)
  end)
  vim.schedule(function()
    -- Ensure that when explorer is open, the descriptions of MiniFiles 'g' mappings stand out.
    local cb_before = function() override_g_globally(g_modified, true) end
    local cb_after = function() override_g_globally(g_originals, false) end
    decorate_miniclue_trigger('g', buf_id, cb_before, cb_after)
  end)
end

local ensure_correct_state = function()
  -- Only when a 'g' or "'" action fails in open explorer, inconsistent state is expected:
  -- 1. global MiniClue.config.clues would remain incorrect
  -- 2. if 'g', the global 'g' mappings still have modified descriptions
  -- Solution: Always restore when explorer closes
  MiniClue.config = miniclue_config_deepcopy
  if g_descriptions_are_modified then override_g_globally(g_originals, false) end
end

local attach_to_already_open = function()
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id) end)
end

local make_cache = function()
  miniclue_config_deepcopy = vim.deepcopy(MiniClue.config)
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

  make_cache()
  attach_to_already_open()
  local augroup = vim.api.nvim_create_augroup('FilesClued', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id) end, 'Show MiniFiles in MiniClue')
  au('User', 'MiniFilesExplorerClose', function() ensure_correct_state() end, 'Ensure state')
end
return FilesClued
