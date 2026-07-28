---@diagnostic disable: undefined-global, inject-field
-- This 'extra' enables showing bookmarks and 'g' mappings from MiniFiles with MiniClue
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

-- The triggers used when explorer is open
local clue_triggers = { { mode = { 'n' }, keys = "'" }, { mode = { 'n' }, keys = 'g' } }
-- The description of a global 'g' mapping in open explorer, for better 'clues' readability
local g_dummy_description = '***'
-- Cache. List with the dictionaries of the original global 'g' mappings
local g_originals = {}
-- Cache. List with the dictionaries of the modified global 'g' mappings
local g_modified = {}

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

-- Ensure that when explorer is open, the descriptions of MiniFiles 'g' mappings stand out.
local override_g_globally = function(g_dictionaries)
  local still_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
  vim.iter(ipairs(g_dictionaries)):filter(still_present):each(function(_, m) vim.fn.mapset(m) end)
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

    -- Don't show global 'config clues' during this 'trigger-char' callback
    MiniClue.config.clues = {}
    cb_before_trigger()
    -- Execute the MiniClue trigger
    miniclue_mapping_info.callback()
    if cb_after_trigger then cb_after_trigger() end
    -- Restore the original "config clues"
    MiniClue.config.clues = clues_orig

    -- MiniClue unmaps on exec and schedules a new map. See MiniClue, H.state_exec
    vim.schedule(function() map_trigger(trigger_char, buf_id, decorated_callback) end)
  end
  map_trigger(trigger_char, buf_id, decorated_callback)
end

local attach = function(buf_id)
  -- Triggers: Restricted to "'" and 'g'
  -- According to discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  MiniClue.config.triggers = clue_triggers
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Decorate triggers to manipulate the clues shown when explorer is open
  -- Important: Calls must be scheduled!
  -- MiniClue unmaps on exec and schedules a new map. See MiniClue, H.state_exec
  vim.schedule(function()
    local cb_before = function() add_mark_mappings(buf_id) end
    decorate_miniclue_trigger("'", buf_id, cb_before)
  end)
  vim.schedule(function()
    local cb_before = function() override_g_globally(g_modified) end
    local cb_after = function() override_g_globally(g_originals) end
    decorate_miniclue_trigger('g', buf_id, cb_before, cb_after)
  end)
end

local attach_to_already_open = function()
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id) end)
end

local cache_global_g_mappings = function()
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

  cache_global_g_mappings()
  attach_to_already_open()
  local augroup = vim.api.nvim_create_augroup('FilesClued', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id) end, 'Show MiniFiles in MiniClue')
end
return FilesClued
