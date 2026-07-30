---@diagnostic disable: undefined-global, inject-field
-- This 'extra' enables showing bookmarks from MiniFiles with MiniClue. The 'g' mappings are opt-in
-- See `:h MiniFiles-examples`
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519
-- Prerequisites: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- Example usage:
--[[
   require('mini.files').setup()
   require('mini.clue').setup()
   -- .. show bookmarks from MiniFiles with MiniClue
   require('<this_file>').setup()
   -- OR: .. also opt-in to 'g'
   require('<this_file>').setup({ with_g = true })
--]]

local decorate = function(buf_id, trigger_char, cb_before, cb_after)
  local map = function(trigger_fn)
    -- See MiniClue->H.map_trigger
    local opts = { nowait = true, buf = buf_id, desc = 'FilesClued for "' .. trigger_char .. '"' }
    vim.keymap.set('n', trigger_char, trigger_fn, opts)
  end
  local miniclue_mapping_info = vim.fn.maparg(trigger_char, 'n', false, true)
  -- Early return when mapping is not buffer local. MiniClue must be enabled...
  if miniclue_mapping_info.buffer ~= 1 then return end

  local trigger_fn
  trigger_fn = function()
    -- Perform any action needed to show the expected clues
    cb_before(buf_id)
    -- Execute the MiniClue trigger
    miniclue_mapping_info.callback()
    -- Undo the actions from 'cb_before_trigger', if applicable
    if cb_after then cb_after(buf_id) end
    -- Ensure continuing trigger_char decoration
    -- MiniClue unmaps on exec and schedules the mapping to be recreated. See MiniClue, H.state_exec
    vim.schedule(function() map(trigger_fn) end)
  end
  map(trigger_fn)
end

local attach = function(buf_id, with)
  -- Triggers: Restricted by "with"
  -- Solution from discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  MiniClue.config.triggers = vim.tbl_map(function(w) return w.trigger_definition end, with)
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Decorate triggers to manipulate the clues displayed when buffer is current
  for _, w in ipairs(with) do
    vim.schedule(function() decorate(buf_id, w.trigger_char, w.cb_before, w.cb_after) end)
  end
end

local augroup = vim.api.nvim_create_augroup('FilesClued', {})
local au = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end

-- Ensure that bookmarks created dynamically are also mapped
local gen_bookmarks_config = function(opts)
  local change_desc = (opts or {}).change_desc or function(obj) return obj end
  local cache = nil

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
  -- Now using a buffer mapping from each bookmark, so mark_goto has to be changed slightly
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
  local get_cache = function()
    if cache then return cache end
    cache = { from_config = vim.tbl_map(function(clue) return change_desc(clue) end, MiniClue.gen_clues.marks()[1]) }
    return cache
  end

  return {
    trigger_char = "'",
    trigger_definition = { mode = { 'n' }, keys = "'" },
    cb_before = function(buf_id)
      vim.iter(pairs(MiniFiles.get_explorer_state().bookmarks)):each(function(id, bookmark)
        vim.keymap.set('n', "'" .. id, function() mark_goto(id) end, { buf = buf_id, desc = bookmark.desc })
      end)
      vim.b[buf_id].miniclue_config = { clues = get_cache().from_config }
    end,
  }
end

-- Ensure that the descriptions of MiniFiles 'g' mappings stand out in explorer
-- This workaround is needed because MiniClue always shows all available clues:
-- 'config clues' -> 'mapping clues' -> 'buffer mapping clues'
local gen_g_config = function(opts)
  local change_desc = (opts or {}).change_desc or function(obj) return obj end
  local cache = nil
  local is_modified = false

  local get_cache = function()
    if cache then return cache end
    local only_g = function(info) return info.lhs:sub(1, 1) == 'g' end
    local g_orig = vim.tbl_filter(only_g, vim.api.nvim_get_keymap('n'))
    local g_modified = vim.tbl_map(function(g) return change_desc(vim.deepcopy(g)) end, g_orig)
    local g_from_config = vim.tbl_map(function(clue) return change_desc(clue) end, MiniClue.gen_clues.g())
    cache = { g_orig = g_orig, g_modified = g_modified, g_from_config = g_from_config }
    return cache
  end
  local override_mappings = function(g_dictionaries, is_override)
    local still_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
    vim.iter(ipairs(g_dictionaries)):filter(still_present):each(function(_, m) vim.fn.mapset(m) end)
    is_modified = is_override
  end

  -- When a 'g' action fails in explorer, the descriptions of global 'g' mappings should be restored
  -- stylua: ignore
  local guard_g = function() if is_modified then override_mappings(get_cache().g_orig, false) end end
  au('User', 'MiniFilesExplorerClose', guard_g, 'Guard descriptions in global g mappings')
  return {
    trigger_char = 'g',
    trigger_definition = { mode = { 'n' }, keys = 'g' },
    cb_before = function(buf_id)
      override_mappings(get_cache().g_modified, true)
      vim.b[buf_id].miniclue_config = { clues = get_cache().g_from_config }
    end,
    cb_after = function() override_mappings(get_cache().g_orig, false) end,
  }
end

local FilesClued = {}
FilesClued.setup = function(config)
  if MiniFiles == nil or MiniClue == nil then return end
  if MiniFiles.config.mappings.mark_goto ~= "'" then return end

  _G.FilesClued = FilesClued
  local config = vim.tbl_deep_extend('force', { with_g = false }, config or {})
  local change_desc = function(obj)
    obj.desc = '     ' .. (obj.desc or '')
    return obj
  end
  local opts = { change_desc = change_desc }
  local with = config.with_g and { gen_bookmarks_config(opts), gen_g_config(opts) } or { gen_bookmarks_config(opts) }

  -- attach to already open
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id, with) end)
  -- attach to new MiniFiles buffers
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id, with) end, 'Show MiniFiles in MiniClue')
end
return FilesClued
