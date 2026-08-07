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
   require('<this_file>').setup() -- See FilesClued.config
--]]

local override = function(buf_id, trigger_char, cb_before)
  local map = function(trigger_fn)
    -- See MiniClue->H.map_trigger
    local opts = { nowait = true, buffer = buf_id, desc = string.format('FilesClued after "%s"', trigger_char) }
    vim.keymap.set('n', trigger_char, trigger_fn, opts)
  end
  local t = vim.fn.maparg(trigger_char, 'n', false, true)
  if not (t.buffer == 1 and t.desc == string.format('Query keys after "%s"', trigger_char)) then return end

  local trigger_fn
  trigger_fn = function()
    -- Perform any action needed to show the expected clues
    cb_before()
    -- Execute the MiniClue trigger
    t.callback()
    -- Ensure continuing trigger_char override. See MiniClue, H.state_exec
    vim.schedule(function() map(trigger_fn) end)
  end
  map(trigger_fn)
end

local attach = function(buf_id, filter_configs)
  -- Triggers, see discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  local configs = filter_configs(buf_id)
  MiniClue.config.triggers = vim.tbl_map(function(c) return c.trigger_definition end, configs)
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Override trigger mappings to manipulate the clues displayed
  vim.schedule(function()
    vim.iter(configs):each(function(c) override(buf_id, c.trigger_definition.keys, c.cb_before) end)
  end)
end

local augroup = vim.api.nvim_create_augroup('FilesClued', {})
local au = function(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
end
local with_desc = function(obj, make_desc_cb)
  obj.desc = make_desc_cb(obj.desc)
  return obj
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

-- Ensure that MiniFiles bookmarks stand out in explorer and are up-to-date
local gen_bookmark_config = function(opts)
  local from_mini = gen_bookmark_code_from_mini_files()
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    local marks = MiniClue.gen_clues.marks()[1]
    cache = { from_config = vim.tbl_map(function(c) return with_desc(c, opts.make_desc) end, marks) }
    return cache
  end

  local cb_before = function()
    local bookmarks = MiniFiles.get_explorer_state().bookmarks
    if vim.tbl_count(bookmarks) == 0 then return end

    -- Promote each MiniFiles bookmark to a buffer-local mapping
    local use_auto_width = false
    vim.iter(pairs(bookmarks)):each(function(id, b)
      local bm_desc = b.desc or vim.fn.fnamemodify(vim.is_callable(b.path) and b.path() or b.path, ':p:~')
      use_auto_width = use_auto_width or b.desc == nil
      vim.keymap.set('n', "'" .. id, function() from_mini.mark_goto(id) end, { buffer = 0, desc = bm_desc })
    end)
    -- Also add buffer overwrites for MiniClue.gen_clues.marks with modified description
    local window = use_auto_width and { config = { width = 'auto' } } or nil
    vim.b.miniclue_config = { clues = get_cache().from_config, window = window }
  end

  return { trigger_definition = { mode = { 'n' }, keys = "'" }, cb_before = cb_before }
end

-- Ensure that the descriptions of MiniFiles 'g' mappings stand out in explorer
local gen_g_config = function(opts)
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    -- Mappings: Global 'g' mappings that don't have a buffer-local override
    local filter_g = function(global_info)
      return global_info.lhs:sub(1, 1) == 'g' and vim.fn.maparg(global_info.lhs, 'n', false, true).buffer ~= 1
    end
    local g_globals = vim.tbl_filter(filter_g, vim.api.nvim_get_keymap('n'))
    local to_buffer_local = function(global_info)
      local res = with_desc(vim.deepcopy(global_info), opts.make_desc)
      res.buffer = 1
      return res
    end
    local g_buffer = vim.tbl_map(function(m) return to_buffer_local(m) end, g_globals)
    -- Config clues:
    local g_config = MiniClue.gen_clues.g()
    g_config = vim.tbl_map(function(clue) return with_desc(clue, opts.make_desc) end, g_config)

    cache = { g_buffer = g_buffer, g_config = g_config }
    return cache
  end

  local cb_before = function()
    -- Promote existing global 'g' mappings to buffer-local with modified description
    local is_present = function(_, m) return vim.fn.maparg(m.lhs, 'n', false, false) ~= '' end
    vim.iter(ipairs(get_cache().g_buffer)):filter(is_present):each(function(_, m) vim.fn.mapset(m) end)
    -- Also add buffer overwrites for MiniClue.gen_clues.g with modified description
    vim.b.miniclue_config = { clues = get_cache().g_config }
  end
  return { trigger_definition = { mode = { 'n' }, keys = 'g' }, cb_before = cb_before }
end

local filter_configs = function(buf_id, bookmark_config, g_config)
  local configs = {}

  -- Ensure presence of buffer-local quote_mapping(MiniFiles default)
  local quote_mapping = vim.tbl_filter(function(m) return m.lhs == "'" end, vim.api.nvim_buf_get_keymap(buf_id, 'n'))
  if #quote_mapping == 1 then table.insert(configs, bookmark_config) end
  if g_config ~= nil then table.insert(configs, g_config) end
  return configs
end

local error = function(msg) error('(FilesClued) ' .. msg, 0) end
local check_type = function(name, val, ref, allow_nil)
  if type(val) == ref or (ref == 'callable' and vim.is_callable(val)) or (allow_nil and val == nil) then return end
  error(string.format('`%s` should be %s, not %s', name, ref, type(val)))
end
local FilesClued = {}

FilesClued.config = {
  -- Clues for all 'g' mappings are opt-in, because there are a lot of them...
  use_g = false,
  -- Change description of clues not specific to MiniFiles. Indent 4 spaces by default
  make_desc = function(desc) return '    ' .. (desc or '') end,
}
local default_config = vim.deepcopy(FilesClued.config)

FilesClued.setup = function(config)
  if MiniFiles == nil or MiniClue == nil then return end
  _G.FilesClued = FilesClued

  check_type('config', config, 'table', true)
  config = vim.tbl_deep_extend('force', default_config, config or {})
  check_type('use_g', config.use_g, 'boolean')
  if not vim.is_callable(config.make_desc) then error('`make_desc` should be callable.') end

  FilesClued.config = config

  local bookmark_config, g_config = gen_bookmark_config(config), config.use_g and gen_g_config(config) or nil
  local filter = function(buf_id) return filter_configs(buf_id, bookmark_config, g_config) end

  -- Attach to already open MiniFiles buffers and subscribe to future MiniFilesBufferCreate events
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id, filter) end)
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id, filter) end, 'MiniFiles with MiniClue')
end
return FilesClued
