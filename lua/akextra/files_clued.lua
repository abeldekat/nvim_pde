---@diagnostic disable: undefined-global, inject-field
-- This 'extra' shows bookmarks from MiniFiles with MiniClue. The 'g' mappings are opt-in
-- Approach: Override specific trigger-mappings after MiniClue.enable_buf_triggers
-- In normal mode this should also works for other regular characters used as triggers
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519 and `:h MiniFiles-examples`
--
-- Requirements: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- Example usage:
--[[
   require('mini.files').setup()
   require('mini.clue').setup()
   require('<this_file>').setup()
   -- OR: .. also opt-in to 'g'
   require('<this_file>').setup({ with_g = true })
--]]

local override = function(buf_id, trigger_char, cb_before, cb_after)
  local map = function(trigger_fn)
    -- See MiniClue->H.map_trigger
    local opts = { nowait = true, buf = buf_id, desc = string.format('FilesClued after "%s"', trigger_char) }
    vim.keymap.set('n', trigger_char, trigger_fn, opts)
  end
  local m = vim.fn.maparg(trigger_char, 'n', false, true)
  if not (m.buffer == 1 and m.desc == string.format('Query keys after "%s"', trigger_char)) then return end
  local miniclue_mapping_info = m

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

local attach = function(buf_id, get_trigger_configs)
  -- Triggers, see discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  local configs = get_trigger_configs(buf_id)
  MiniClue.config.triggers = vim.tbl_map(function(c) return c.trigger_definition end, configs)
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Override trigger mappings to manipulate the clues displayed
  for _, c in ipairs(configs) do
    vim.schedule(function() override(buf_id, c.trigger_char, c.cb_before, c.cb_after) end)
  end
end

local augroup = vim.api.nvim_create_augroup('FilesClued', {})
local au = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end

local gen_bookmark_code_from_mini_files = function()
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
  -- When using a buffer mapping from each bookmark, mark_goto has to be changed slightly
  local mark_goto = function(id)
    local state = MiniFiles.get_explorer_state()
    local path = state.bookmarks[id].path
    if vim.is_callable(path) then path = path() end
    local is_valid_path = type(path) == 'string' and fs_get_type(vim.fn.expand(path)) == 'directory'
    if not is_valid_path then return notify('Bookmark path should be a valid path to directory', 'WARN') end

    MiniFiles.set_bookmark("'", state.branch[state.depth_focus], { desc = 'Before latest jump' })
    MiniFiles.set_branch({ path })
  end
  return { mark_goto = mark_goto }
end

-- Ensure that bookmarks stand out in explorer and are up-to-date
local gen_bookmark_config = function(opts)
  local from_mini = gen_bookmark_code_from_mini_files()
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    cache = { from_config = vim.tbl_map(function(c) return opts.change_desc(c) end, MiniClue.gen_clues.marks()[1]) }
    return cache
  end

  return {
    trigger_char = "'",
    trigger_definition = { mode = { 'n' }, keys = "'" },
    cb_before = function(buf_id)
      local bookmarks = MiniFiles.get_explorer_state().bookmarks
      if vim.tbl_count(bookmarks) == 0 then return end

      local use_auto_width = false
      vim.iter(pairs(bookmarks)):each(function(id, b)
        local desc = b.desc or vim.fn.fnamemodify(vim.is_callable(b.path) and b.path() or b.path, ':p:~')
        vim.keymap.set('n', "'" .. id, function() from_mini.mark_goto(id) end, { buf = buf_id, desc = desc })
        use_auto_width = use_auto_width or b.desc == nil
      end)
      local window = use_auto_width and { config = { width = 'auto' } } or nil
      vim.b[buf_id].miniclue_config = { clues = get_cache().from_config, window = window }
    end,
  }
end

-- Ensure that the descriptions of MiniFiles 'g' mappings stand out in explorer
local gen_g_config = function(opts)
  local is_dirty = false
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    local only_g = function(info) return info.lhs:sub(1, 1) == 'g' end
    local g_orig = vim.tbl_filter(only_g, vim.api.nvim_get_keymap('n'))
    local g_modified = vim.tbl_map(function(g) return opts.change_desc(vim.deepcopy(g)) end, g_orig)
    local g_from_config = vim.tbl_map(function(clue) return opts.change_desc(clue) end, MiniClue.gen_clues.g())
    cache = { g_orig = g_orig, g_modified = g_modified, g_from_config = g_from_config }
    return cache
  end

  local override_mappings = function(g_dictionaries, is_override)
    local still_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
    vim.iter(ipairs(g_dictionaries)):filter(still_present):each(function(_, m) vim.fn.mapset(m) end)
    is_dirty = is_override
  end

  -- When a 'g' action fails in explorer, the descriptions of global 'g' mappings should be restored
  -- stylua: ignore
  local guard_g = function() if is_dirty then override_mappings(get_cache().g_orig, false) end end
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

local error = function(msg) error('(FilesClued) ' .. msg, 0) end
local check_type = function(name, val, ref, allow_nil)
  if type(val) == ref or (ref == 'callable' and vim.is_callable(val)) or (allow_nil and val == nil) then return end
  error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end
local FilesClued = {}
FilesClued.config = {
  use_g = false,
  change_desc = function(obj)
    obj.desc = '    ' .. (obj.desc or '')
    return obj
  end,
}
local default_config = vim.deepcopy(FilesClued.config)

-- MiniClue always shows all available clues: 'config clues' -> 'mapping clues' -> 'buffer mapping clues'
FilesClued.setup = function(config)
  if MiniFiles == nil or MiniClue == nil then return end
  _G.FilesClued = FilesClued

  check_type('config', config, 'table', true)
  config = vim.tbl_deep_extend('force', default_config, config or {})
  check_type('use_g', config.use_g, 'boolean')
  if not vim.is_callable(config.change_desc) then error('`change_desc` should be callable.') end

  FilesClued.config = config

  local bookmark_config, g_config = gen_bookmark_config(config), config.use_g and gen_g_config(config) or nil
  local get = function(buf_id)
    local configs = {}
    local quote_mapping = vim.tbl_filter(function(m) return m.lhs == "'" end, vim.api.nvim_buf_get_keymap(buf_id, 'n'))
    if #quote_mapping == 1 then table.insert(configs, bookmark_config) end
    if g_config ~= nil then table.insert(configs, g_config) end
    return configs
  end
  -- attach to already open and subscribe to MiniFilesBufferCreate
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id, get) end)
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id, get) end, 'MiniFiles with MiniClue')
end
return FilesClued
