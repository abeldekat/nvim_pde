---@diagnostic disable: undefined-global, inject-field
-- This 'extra' shows bookmarks from MiniFiles with MiniClue. The 'g' mappings are opt-in
-- Approach: Override the relevant trigger-mappings after MiniClue.enable_buf_triggers
-- See https://github.com/nvim-mini/mini.nvim/discussions/2519 and `:h MiniFiles-examples`
--
-- Requirements: MiniFiles and MiniClue active. MiniFiles uses default mark_goto mapping
-- Example usage:
--[[
   require('mini.files').setup()
   require('mini.clue').setup()
   require('<this_file>').setup() -- See FilesClued.config
--]]

local override = function(buf_id, keys, trigger_pre_cb)
  local map = function(trigger_fn)
    -- See MiniClue -> H.map_trigger
    local opts = { nowait = true, buffer = buf_id, desc = string.format('FilesClued after "%s"', keys) }
    vim.keymap.set('n', keys, trigger_fn, opts)
  end

  local local_keys = vim.api.nvim_buf_get_keymap(buf_id, 'n')
  local trigger = vim.tbl_filter(function(info) return info.lhs == keys end, local_keys)[1]
  if not (trigger and trigger.desc == string.format('Query keys after "%s"', keys)) then return end

  local trigger_override
  trigger_override = function()
    -- Perform any action needed to show the expected clues
    trigger_pre_cb()
    -- Execute the MiniClue trigger
    trigger.callback()
    -- Ensure continuing "keys" override. See MiniClue, H.state_exec
    vim.schedule(function() map(trigger_override) end)
  end
  map(trigger_override)
end

local attach = function(buf_id, use_cb)
  -- Triggers, see discussion: https://github.com/nvim-mini/mini.nvim/discussions/1195#discussioncomment-10542838
  local triggers_orig = MiniClue.config.triggers
  local use = use_cb(buf_id)
  MiniClue.config.triggers = vim.tbl_map(function(u) return u.trigger_definition end, use)
  MiniClue.enable_buf_triggers(buf_id)
  MiniClue.config.triggers = triggers_orig

  -- Clues: Ensure that 'trigger_pre' runs before MiniClue's trigger handler
  local override_with = function(u) override(buf_id, u.trigger_definition.keys, u.trigger_pre) end
  vim.schedule(function() vim.iter(use):each(override_with) end)
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

  -- MiniFiles -> H.buffer_make_mappings -> mark_goto uses its 'H.getcharstr' to obtain the id
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
local gen_bookmark = function(opts)
  local from_mini = gen_bookmark_code_from_mini_files()
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    local marks = MiniClue.gen_clues.marks()[1]
    cache = { from_config = vim.tbl_map(function(c) return with_desc(c, opts.make_desc) end, marks) }
    return cache
  end

  local trigger_pre = function()
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

  return { trigger_definition = { mode = { 'n' }, keys = "'" }, trigger_pre = trigger_pre }
end

-- Ensure that the descriptions of MiniFiles 'g' mappings stand out in explorer
local gen_g = function(opts)
  local cache = nil

  local get_cache = function()
    if cache then return cache end

    -- Mappings: Global 'g' mappings that don't have a buffer-local override
    local is_local = function(info) return vim.fn.maparg(info.lhs, 'n', false, true).buffer == 1 end
    local filter_g = function(info) return info.lhs:sub(1, 1) == 'g' and not is_local(info) end
    local g_globals = vim.tbl_filter(filter_g, vim.api.nvim_get_keymap('n'))
    local to_local = function(info)
      local res = with_desc(vim.deepcopy(info), opts.make_desc)
      res.buffer = 1
      return res
    end
    local g_to_local = vim.tbl_map(function(info) return to_local(info) end, g_globals)
    -- Config clues:
    local g_config = MiniClue.gen_clues.g()
    g_config = vim.tbl_map(function(clue) return with_desc(clue, opts.make_desc) end, g_config)

    cache = { to_local = g_to_local, from_config = g_config }
    return cache
  end

  local trigger_pre = function()
    -- Promote existing global 'g' mappings to buffer-local with modified description
    local is_present = function(_, info) return vim.fn.maparg(info.lhs, 'n', false, false) ~= '' end
    vim.iter(ipairs(get_cache().to_local)):filter(is_present):each(function(_, info) vim.fn.mapset(info) end)
    -- Also add buffer overwrites for MiniClue.gen_clues.g with modified description
    vim.b.miniclue_config = { clues = get_cache().from_config }
  end
  return { trigger_definition = { mode = { 'n' }, keys = 'g' }, trigger_pre = trigger_pre }
end

local filter = function(buf_id, bookmark_def, g_def)
  -- Ensure presence of single quote buffer mapping(MiniFiles mark_goto)
  local local_keys = vim.api.nvim_buf_get_keymap(buf_id, 'n')
  local quote_mapping = vim.tbl_filter(function(info) return info.lhs == "'" end, local_keys)

  local result = {}
  if #quote_mapping == 1 then table.insert(result, bookmark_def) end
  if g_def ~= nil then table.insert(result, g_def) end
  return result
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

  local bookmark_def, g_def = gen_bookmark(config), config.use_g and gen_g(config) or nil
  local use = function(buf_id) return filter(buf_id, bookmark_def, g_def) end

  -- Attach to already open MiniFiles buffers
  local list_bufs, is_loaded = vim.api.nvim_list_bufs, vim.api.nvim_buf_is_loaded
  local is_files = function(buf_id) return vim.bo[buf_id].filetype == 'minifiles' end
  vim.iter(list_bufs()):filter(is_loaded):filter(is_files):each(function(buf_id) attach(buf_id, use) end)

  -- Subscribe to future MiniFilesBufferCreate events
  local augroup = vim.api.nvim_create_augroup('FilesClued', {})
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au('User', 'MiniFilesBufferCreate', function(args) attach(args.data.buf_id, use) end, 'MiniFiles with MiniClue')
end
return FilesClued
