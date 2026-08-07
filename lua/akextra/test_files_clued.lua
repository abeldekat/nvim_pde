---@diagnostic disable: undefined-global
local helpers = dofile('lua/akextra/helpers.lua')
local child = helpers.new_child_neovim()
local expect, eq = helpers.expect, helpers.expect.equality
local new_set = MiniTest.new_set

-- Helpers with child processes
local load_module = function(config) child.akextra_load('files_clued', config) end
local unload_module = function() child.akextra_unload('files_clued', 'FilesClued') end
local load_module_files = function(config) child.mini_load('files', config) end
local load_module_clue = function(config) child.mini_load('clue', config) end
local type_keys = function(...) return child.type_keys(...) end
local forward_lua = function(fun_str) return helpers.forward_lua(child, fun_str) end

-- Test paths helpers
local normalize_path = function(p) return (p:gsub('\\', '/'):gsub('(.)/$', '%1')) end
if helpers.is_windows() then
  normalize_path = function(p) return (p:gsub('\\', '/'):gsub('(.)/$', '%1'):gsub('^(%a):/+([^/])', '%1://%2')) end
end
local join_path = function(...) return table.concat({ ... }, '/') end
local full_path = function(...) return normalize_path(vim.fn.fnamemodify(join_path(...), ':p')) end

-- Custom validators
local validate_trigger_keymap = function(mode, keys, buf_id)
  buf_id = buf_id or child.api.nvim_get_current_buf()
  local lua_cmd = string.format(
    [[vim.api.nvim_buf_call(%s, function() return vim.fn.maparg(%s, %s, false, true).desc end)]],
    buf_id,
    vim.inspect(keys),
    vim.inspect(mode)
  )
  local map_desc = child.lua_get(lua_cmd)
  if map_desc == vim.NIL then error('No such trigger.') end

  local desc_pattern = 'FilesClued after.*"' .. vim.pesc(keys) .. '"'
  expect.match(map_desc, desc_pattern)
end

local validate_no_trigger_keymap = function(mode, keys, buf_id, error)
  expect.error(function() validate_trigger_keymap(mode, keys, buf_id) end, error)
end

-- Common test wrappers
local open = forward_lua('MiniFiles.open')
local go_out = forward_lua('MiniFiles.go_out')
local close = forward_lua('MiniFiles.close')
local get_explorer_state = forward_lua('MiniFiles.get_explorer_state')
local set_bookmark = forward_lua('MiniFiles.set_bookmark')

-- Common mocks
local mock_win_functions = function() child.cmd('source tests/dir-files_clued/mock-win-functions.lua') end
local mock_map_functions = function()
  child.lua([[
    local mock_desc = function(x)
      if type(x) ~= 'string' then return x end
      -- Make sure that full path used in description is the same on any machine
      return x:gsub('^~/(.+)/tests/dir%-files_clued', function(m)
        -- Account for possible title truncation.
        local mocked_root = string.sub('MOCK_ROOT', -vim.fn.strdisplaywidth(m))
        return mocked_root .. '/tests/dir-files_clued'
      end)
    end

    _G.keymap_set = vim.keymap.set
    vim.keymap.set = function(modes, lhs, rhs, opts)
      opts = opts or {}
      opts.desc = mock_desc(opts.desc)
      keymap_set(modes, lhs, rhs, opts)
    end
  ]])
end

-- Hooks ======================================================================
local hooks_pre_case_integration = function()
  mock_win_functions()

  -- Mock `vim.notify()`
  child.lua([[
    _G.notify_log = {}
    vim.notify = function(...) table.insert(_G.notify_log, { ... }) end
  ]])

  -- Make more robust screenshots
  child.o.laststatus = 0
  child.o.showtabline = 0

  -- Hide intro
  child.cmd('vsplit')
  child.cmd('quit')
end

-- Data =======================================================================
local quote = "'"
local test_dir_path = 'tests/dir-files_clued/common'
local test_file_path = 'tests/dir-files_clued/common/a-file'

-- Output test set ============================================================
local T = new_set({
  hooks = {
    pre_case = function() child.setup() end,
    post_once = child.stop,
  },
  n_retry = helpers.get_n_retry(1),
})

T['setup()'] = new_set()

T['setup()']['requires MiniFiles and MiniClue'] = function()
  load_module()
  eq(child.lua_get('type(_G.FilesClued)'), 'nil')
end

T['setup()']['creates side effects'] = function()
  child.lua('_G.MiniFiles = {} _G.MiniClue = {}')
  load_module()
  -- Global variable and  autocommand group
  eq(child.lua_get('type(_G.FilesClued)'), 'table')
  eq(child.fn.exists('#FilesClued'), 1)
end

T['setup()']['creates `config` field'] = function()
  child.lua('_G.MiniFiles = {} _G.MiniClue = {}')
  load_module()
  eq(child.lua_get('type(_G.FilesClued.config)'), 'table')

  -- Check default values
  local expect_config_type = function(field, type_val)
    eq(child.lua_get('type(FilesClued.config.' .. field .. ')'), type_val)
  end
  local expect_config = function(field, value) eq(child.lua_get('FilesClued.config.' .. field), value) end

  expect_config('use_g', false)
  expect_config_type('make_desc', 'function')
end

T['setup()']['respects `config` argument'] = function()
  child.lua('_G.MiniFiles = {} _G.MiniClue = {}')
  -- Check setting `FilesClued.config` fields
  load_module({ use_g = true })
  eq(child.lua_get('FilesClued.config.use_g'), true)
end

T['setup()']['validates `config` argument'] = function()
  unload_module()
  child.lua([[ MiniFiles = {} MiniClue = {} ]])

  local expect_config_error = function(config, name, target_type)
    expect.error(function() load_module(config) end, vim.pesc(name) .. '.*' .. vim.pesc(target_type))
  end
  expect_config_error('a', 'config', 'table')
  expect_config_error({ use_g = 'a' }, 'use_g', 'boolean')
  expect_config_error({ make_desc = 'a' }, 'make_desc', 'function')
end

T['setup()']['creates triggers for already created MiniFiles buffers'] = function()
  local init_buf_id = child.api.nvim_create_buf(true, false)
  child.lua(string.format('vim.bo[%d].filetype = "minifiles"', init_buf_id))
  local other_buf_id = child.api.nvim_create_buf(true, false)
  child.lua(string.format('vim.bo[%d].filetype = "minifiles"', other_buf_id))

  child.lua('_G.MiniFiles = {}')
  load_module_clue({ triggers = { { mode = 'n', keys = "'" } } })
  load_module({ triggers = { { mode = 'n', keys = "'" } } })

  validate_trigger_keymap('n', "'", init_buf_id)
  validate_trigger_keymap('n', "'", other_buf_id)
end

T['attach()'] = new_set()

T['attach()']['only attaches when it can overwrite existing clue mapping'] = function()
  load_module_files()
  child.lua([[
    _G.MiniClue = {}
    _G.MiniClue.config = {}
    _G.MiniClue.enable_buf_triggers = function() end
  ]])
  load_module()
  open(test_file_path)
  validate_no_trigger_keymap('n', "'", init_buf_id, 'Go to bookmark')
end

T['Mappings'] = new_set({
  hooks = {
    pre_case = function() hooks_pre_case_integration() end,
  },
})

T['Mappings'][quote] = new_set({
  hooks = {
    pre_case = function()
      load_module_files()
      load_module_clue({
        triggers = { { mode = 'n', keys = "'" } },
        window = { delay = 0 },
      })
      child.lua([[
        MiniClue.config.clues = { MiniClue.gen_clues.marks() }
      ]])
      load_module()
    end,
  },
})

T['Mappings'][quote]['works'] = function()
  open(test_file_path)
  set_bookmark('c', test_dir_path, { desc = 'nvim config' })
  set_bookmark('m', test_dir_path, { desc = 'same as c' })
  type_keys("'")
  child.expect_screenshot()
  type_keys('c', "'")

  -- Ensure that new bookmark "before last jump" is also visible
  child.expect_screenshot()
  type_keys("'")

  -- Explorer still open in previous tab. Expect clues without MiniFiles bookmarks
  local tab_explorer = child.api.nvim_get_current_tabpage()
  child.cmd('tabnew')
  local tab_new = child.api.nvim_get_current_tabpage()
  expect.no_equality(tab_new, tab_explorer)
  type_keys("'")
  child.expect_screenshot()
  type_keys('<Esc>')

  -- Close explorer. Expect clues without MiniFiles bookmarks
  type_keys('gt')
  eq(child.api.nvim_get_current_tabpage(), tab_explorer)
  close()
  type_keys("'")
  child.expect_screenshot()
end

T['Mappings'][quote]['only modifies descriptions if there are MiniFiles bookmarks'] = function()
  open(test_file_path)
  type_keys("'")
  child.expect_screenshot()
  close()
end

T['Mappings'][quote]['uses width "auto" if there is a MiniFiles bookmark without description'] = function()
  open(test_file_path)

  -- Simulate pressing "m" by setting a bookmark without description
  set_bookmark('c', test_dir_path)
  mock_map_functions()
  type_keys("'")
  child.expect_screenshot()
  close()
end

T['Mappings'][quote]['allows to override the customization of descriptions'] = function()
  -- No indentation:
  child.lua([[
    FilesClued.config.make_desc = function(desc) return desc end
  ]])
  open(test_file_path)
  set_bookmark('c', test_dir_path, { desc = 'NO INDENTATION' })
  type_keys("'")
  child.expect_screenshot()
end

-- Relevant tests copied from MiniFiles should still work
T['Mappings'][quote]['MiniFiles_tests'] = new_set()

local get_branch = function() return child.lua_get('(MiniFiles.get_explorer_state() or {}).branch') end

-- NOTE: "Warns about not existing bookmark id": not possible with mappings
T['Mappings'][quote]['MiniFiles_tests']['`mark_goto` works'] = function()
  local validate_log = function(ref_log)
    eq(child.lua_get('_G.notify_log'), ref_log)
    child.lua('_G.notify_log = {}')
  end

  local path = full_path(test_dir_path)
  local mark_path = path .. '/a-dir'
  open(path)
  set_bookmark('a', mark_path)
  go_out()
  expect.no_equality(get_branch(), { mark_path })
  type_keys("'", 'a')
  eq(get_branch(), { mark_path })
  -- - Should show no notifications
  validate_log({})

  -- Warns about not existing bookmark id
  go_out()
  local ref_branch = get_branch()
  -- type_keys("'", 'x')
  -- eq(get_branch(), ref_branch)
  -- local warn_level = child.lua_get('vim.log.levels.WARN')
  -- validate_log({ { '(mini.files) No bookmark with id "x"', warn_level } })

  -- Does nothing (silently) after `<Esc>` or `<C-c>`
  type_keys("'", '<Esc>')
  eq(get_branch(), ref_branch)
  validate_log({})
  -- - <C-c> should stop even if it doesn't make `getcharstr` error
  child.cmd('nnoremap <C-c> <C-\\><C-n>')
  type_keys("'", '<C-c>')
  eq(get_branch(), ref_branch)
  validate_log({})

  close()

  -- User-supplied
  open(path, false, { mappings = { mark_goto = '`' } })
  set_bookmark('a', mark_path)
  go_out()
  type_keys('`', 'a')
  eq(get_branch(), { mark_path })
  close()

  -- Empty
  open(path, false, { mappings = { mark_goto = '' } })
  set_bookmark('a', mark_path)
  go_out()
  expect.error(function() type_keys("'", 'a') end, 'E20')
end

T['Mappings'][quote]['MiniFiles_tests']["`mark_goto` automatically sets `'` bookmark"] = function()
  local get_cur_path = function()
    local state = get_explorer_state()
    return state.branch[state.depth_focus]
  end

  local path = full_path(test_dir_path)
  local mark_path = path .. '/a-dir'
  open(path)
  set_bookmark('a', mark_path)

  go_out()
  local path_before_jump = get_cur_path()
  eq(get_explorer_state().bookmarks["'"], nil)
  type_keys("'", 'a')
  eq(get_branch(), { mark_path })
  eq(get_explorer_state().bookmarks["'"], { desc = 'Before latest jump', path = path_before_jump })

  type_keys("'", "'")
  eq(get_branch(), { path_before_jump })
  eq(get_explorer_state().bookmarks["'"], { desc = 'Before latest jump', path = mark_path })
end

T['Mappings'][quote]['MiniFiles_tests']['`mark_goto` works with special paths'] = function()
  local validate_log = function(ref_log)
    eq(child.lua_get('_G.notify_log'), ref_log)
    child.lua('_G.notify_log = {}')
  end
  local warn_level = child.lua_get('vim.log.levels.WARN')
  local cwd = normalize_path(child.fn.getcwd())

  local path = full_path(test_dir_path)
  open(path)

  -- Relative paths (should be resolved against cwd, not currently focused)
  local path_rel = test_dir_path .. '/a-dir'
  set_bookmark('a', path_rel)
  type_keys("'", 'a')
  eq(get_branch(), { full_path(path_rel) })

  -- Involving '~'
  set_bookmark('~', '~')
  type_keys("'", '~')
  expect.no_equality(get_branch(), { full_path(path_rel) })
  validate_log({})

  -- Function paths
  child.lua([[MiniFiles.set_bookmark('b', vim.fn.getcwd)]])
  type_keys("'", 'b')
  eq(get_branch(), { cwd })

  -- Not existing on disk
  child.lua([[MiniFiles.set_bookmark('c', function() return vim.fn.getcwd() .. '/not-present' end)]])
  type_keys("'", 'c')
  eq(get_branch(), { cwd })
  validate_log({ { '(FilesClued) Bookmark path should be a valid path to directory', warn_level } })

  -- Not directory path
  child.lua('_G.file_path = ' .. vim.inspect(full_path(test_file_path)))
  child.lua([[MiniFiles.set_bookmark('d', function() return _G.file_path end)]])
  type_keys("'", 'd')
  eq(get_branch(), { cwd })
  validate_log({ { '(FilesClued) Bookmark path should be a valid path to directory', warn_level } })
end

T['Mappings']['g'] = new_set({
  hooks = {
    pre_case = function()
      child.set_size(24, 85)
      load_module_files()
      load_module_clue({
        triggers = { { mode = 'n', keys = 'g' } },
        window = { delay = 0 },
      })
      child.lua([[
        MiniClue.config.clues = { MiniClue.gen_clues.g() }
      ]])
      child.lua([[
        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniFilesBufferCreate',
          callback = function(args)
            local opts = { desc = "Toggle dotfiles", buffer = args.data.buf_id }
            vim.keymap.set('n', 'gd', "<Cmd><CR>", opts) end
        })
      ]])
      load_module({ use_g = true })
    end,
  },
})

T['Mappings']['g']['is disabled by default'] = function()
  unload_module()
  load_module()
  open(test_file_path)
  validate_no_trigger_keymap('n', 'g')
end

T['Mappings']['g']['works'] = function()
  open(test_file_path)
  type_keys('g')
  child.expect_screenshot()
  type_keys('g')

  -- Ensure works again in open explorer
  type_keys('g')
  child.expect_screenshot()
  type_keys('g')

  -- Explorer still open in previous tab. Expect clues without MiniFiles 'g' mappings
  local tab_explorer = child.api.nvim_get_current_tabpage()
  child.cmd('tabnew')
  local tab_new = child.api.nvim_get_current_tabpage()
  expect.no_equality(tab_new, tab_explorer)
  type_keys('g')
  child.expect_screenshot()
  type_keys('<Esc>')

  -- Close explorer. Expect clues without MiniFiles 'g' mappings
  type_keys('gt')
  eq(child.api.nvim_get_current_tabpage(), tab_explorer)
  close()
  type_keys('g')
  child.expect_screenshot()
end

T['Mappings']['g']['allows to override the customization of descriptions'] = function()
  -- No change(indentation)
  child.lua([[
    FilesClued.config.make_desc = function(desc) return desc end
  ]])
  open(test_file_path)
  type_keys('g')
  child.expect_screenshot()
  close()
end

T['Mappings']['g']['does not overwrite already existing buffer mappings'] = function()
  child.lua([[
    vim.keymap.set('n', 'gd', '<Cmd><CR>', { desc = 'Dummy global mapping' })
  ]])
  -- Create MiniFiles 'gd' mapping
  open(test_file_path)
  type_keys('g')
  -- Expect description of MiniFiles 'gd' buffer mapping
  child.expect_screenshot()
end

T['Mappings']['g']['does not restore a deleted global mapping'] = function()
  -- Initialize cache with global mappings to override
  open(test_file_path)
  type_keys('g', '<Esc>')
  close()

  -- Delete global mappings
  child.api.nvim_del_keymap('n', 'gcc')
  child.api.nvim_del_keymap('n', 'gc')

  -- Ensure that the copy in cache is not used anymore
  open(test_file_path)
  type_keys('g')
  child.expect_screenshot()
end

return T
