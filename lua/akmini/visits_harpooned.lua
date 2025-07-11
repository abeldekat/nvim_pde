-- Replaces harpoon. See https://github.com/echasnovski/mini.nvim/discussions/1158
-- Configures MiniVisits to work with labels in the same way as Harpoon works with lists.
--
-- This setup works with one visit index file per project dir
-- Tested to also operate correctly when using MiniMisc.setup_auto_root: vim.fn.changedir on BufEnter.
--
-- Requirements:
-- 1. MiniPick active
-- 2. Restore cursor functionality. See MiniMisc.setup_restore_cursor
-- 3. MiniVisits not active. Its setup is invoked here

local VisitsHarpooned, H = {}, {}

VisitsHarpooned.setup = function(config)
  _G.VisitsHarpooned = VisitsHarpooned
  H.setup_config(config)
  H.create_autocommands()

  local Visits = require("mini.visits")
  Visits.setup({
    list = { sort = H.sort_recency },
    silent = true,
    store = {
      autowrite = false,
      normalize = H.gen_normalize_to_delete_unlabeled(Visits.gen_normalize.default()),
      path = H.make_project_store_path(),
    },
    track = { event = "" }, -- add visits programatically
  })
end

-- Intended to be used when generating a statusline component
VisitsHarpooned.as_provider = function()
  return {
    events = H.events,
    get_label = function() return H.state.label end,
    list_paths = function() return H.list_paths() end,
    full_path_of_current_buffer = function() return H.full_path_of_current_buffer() end,
  }
end

VisitsHarpooned.toggle = function()
  local full_path = H.full_path_of_current_buffer()
  if vim.list_contains(H.list_paths(), full_path) then
    MiniVisits.remove_label(H.state.label, full_path, H.all_cwd)
  else
    MiniVisits.register_visit(full_path, H.dummy_cwd) -- must update "latest" field
    MiniVisits.add_label(H.state.label, full_path, H.dummy_cwd)
  end
  H.on_change()
end

VisitsHarpooned.select = function(i)
  local ft = vim.bo.ft
  if ft and ft == "minifiles" then MiniFiles.close() end
  MiniVisits.iterate_paths("first", H.all_cwd, { filter = H.state.label, n_times = i })
end

VisitsHarpooned.pick_from_all = function() H.visits_by_labels(H.list_labels()) end

VisitsHarpooned.pick_from_current = function() H.visits_by_labels(H.state.label) end

VisitsHarpooned.switch_label = function()
  local name = "Visits change active label"
  local picker_items = H.list_labels()
  local choose = function(label) H.switch_label(label) end
  local source = { name = name, items = picker_items, choose = choose }
  local hinted = { enable = true, use_autosubmit = true, chars = H.config.picker_hints_on_switch_label }
  return MiniPick.start({ source = source, hinted = hinted })
end

VisitsHarpooned.new_label = function()
  local full_path = H.full_path_of_current_buffer()

  local old = MiniVisits.list_labels(full_path, H.dummy_cwd)
  MiniVisits.add_label(nil, full_path, H.dummy_cwd)
  local new = MiniVisits.list_labels(full_path, H.dummy_cwd)

  if #new == #old then return end

  local added = vim.tbl_filter(function(label) return not vim.list_contains(old, label) end, new)
  if #added ~= 1 then return end

  MiniVisits.write_index()
  H.switch_label(added[1])
end

VisitsHarpooned.maintain = function() -- like mini.deps, H.update_feedback_confirm, copied and modified
  local label = H.state.label
  local report = {
    string.format("Maintain visits that are labeled with [%s]", label),
    "",
    string.format("1. Remove lines to remove visits from [%s]", label),
    string.format("2. Reorder lines to define the order of files in [%s]", label),
    "3. Otherwise, use toggle visits(leader a)",
    "",
    "Write to save, quit to cancel:",
    "",
  }
  local n_header = #report
  local items = vim.tbl_map(function(full_path) -- show short paths...
    return H.short_path(full_path)
  end, H.list_paths())
  vim.list_extend(report, items)

  local finish = function(buf_id)
    local paths = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf_id, n_header, -1, false)) do
      table.insert(paths, H.full_path(l)) -- update full paths...
    end
    H.batch_update(paths)
  end
  local name = string.format("visits-ak://maintain-%s", label)
  H.maintain.show(report, { name = name, exec_on_write = finish, n_header = n_header })
end

VisitsHarpooned.clear_all_visits = function()
  MiniVisits.remove_path(H.all_paths, H.all_cwd) -- remove all *visits*
  H.on_change()
  H.switch_label(H.config.start_label) -- auto-switch to start
end

-- Helper ================================================================

-- start_label is the only label that is always present, even when not attached to visits:
H.config = { start_label = "core", picker_hints_on_switch_label = { "j", "k", "l", "h" } }
H.default_config = vim.deepcopy(H.config)
H.store_dir = string.format("%s/%s", vim.fn.stdpath("data"), "visits_harpooned")
H.maintain_ft = "visits-harpooned-maintain"
H.maintain = {}
H.all_cwd, H.all_paths = "", "" -- constants as expected by MiniVisits
H.state = { label = nil }
H.events = { modified = "VisitsHarpoonedModified" }

-- The index file is stored per project dir, so key 'cwd' can always be the same
H.dummy_cwd = string.format("%s", vim.fn.expand("~")) -- guaranteed to exist

H.setup_config = function(config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})
  local val = vim.validate

  vim.validate("MiniVisits", MiniVisits, "nil") -- mini.visits should not be active
  vim.validate("MiniPick", MiniPick, "table")
  vim.validate("config", config, "table")
  vim.validate("start_label", config.start_label, "string")
  vim.validate("picker_hints_on_switch_label", config.picker_hints_on_switch_label, "table")
  vim.validate(
    "picker_hints_on_switch_label",
    config.picker_hints_on_switch_label,
    function(x) return H.is_list_of(x, "picker_hints_on_switch_label", "string") end
  )

  H.config = config
  H.state.label = config.start_label
end

H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("VisitsHarpooned", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("FileType", H.maintain_ft, function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end)
  au("User", "MiniFilesExplorerClose", function(_) -- No BufEnter on close
    local exec_opts = { pattern = H.events.modified, modeline = false }
    vim.schedule(function() vim.api.nvim_exec_autocmds("User", exec_opts) end)
  end)
end

H.list_paths = function(label) return MiniVisits.list_paths(H.all_cwd, { filter = label or H.state.label }) end

H.full_path_of_current_buffer = function()
  local ft = vim.bo.ft
  if not (ft and ft == "minifiles") then return vim.fn.expand("%:p") end

  local state = MiniFiles.get_explorer_state()
  return state and state.branch[state.depth_focus] or nil
end

H.list_labels = function()
  local labels = vim.tbl_filter(
    function(label) return label ~= H.config.start_label end,
    MiniVisits.list_labels(H.all_paths, H.all_cwd)
  )
  table.insert(labels, 1, H.config.start_label) -- ensure start label at first position
  return labels
end

H.on_change = function()
  vim.api.nvim_exec_autocmds("User", { pattern = H.events.modified, modeline = false })
  MiniVisits.write_index()
end

H.switch_label = function(label)
  H.state.label = label
  vim.api.nvim_exec_autocmds("User", { pattern = H.events.modified, modeline = false })
end

H.batch_update = function(paths_from_user)
  MiniVisits.remove_label(H.state.label, H.all_paths, H.all_cwd)

  local index = MiniVisits.get_index()
  index = vim.tbl_isempty(index) and { [H.dummy_cwd] = {} } or index
  local time = os.time()
  local for_cwd = index[H.dummy_cwd]
  for ind, path in ipairs(paths_from_user) do -- os.time: in seconds
    local data = for_cwd[path] or { latest = 0, count = 0 }
    data.latest = time + ind -- ensure 1 second difference with previous
    data.labels = data.labels and data.labels or {}
    data.labels[H.state.label] = true -- add the label
    for_cwd[path] = data
  end

  MiniVisits.set_index(index)
  H.on_change()
end

H.gen_normalize_to_delete_unlabeled = function(normalize_default)
  return function(index) -- keep visits with labels, remove others
    index = normalize_default(index)
    for _, paths in pairs(index) do
      for path, path_data in pairs(paths) do
        if not path_data.labels then paths[path] = nil end
      end
    end
    return index
  end
end

H.make_project_store_path = function() -- Good enough, but not guaranteed to be unique
  local result = string.format("%s/%s", H.store_dir, "index")
  local cwd = vim.fn.getcwd()
  local cwd_to_number = 1
  for i = 1, #cwd do -- transform cwd to a number
    cwd_to_number = cwd_to_number + string.byte(cwd, i)
  end
  return string.format("%s-%d-%s", result, cwd_to_number, vim.fn.fnamemodify(cwd, ":t"))
end

H.sort_recency = function(path_data_arr)
  table.sort(path_data_arr, function(a, b) return a.latest < b.latest end)
  return path_data_arr
end

H.visits_by_labels = function(labels) -- a customized Extra.pickers.visit_paths
  local for_specific_label = type(labels) == "string"
  labels = for_specific_label and { labels } or labels

  local paths_to_items = function(paths, label)
    return vim.tbl_map(function(visit_path)
      local text_path = H.short_path(visit_path)
      return { path = visit_path, text = string.format(" %-6s %s", label, H.short_path(visit_path)) }
    end, paths)
  end
  local picker_items = vim.schedule_wrap(function()
    local items = {}
    for _, label in ipairs(labels) do
      local paths = H.list_paths(label)
      if paths then vim.list_extend(items, paths_to_items(paths, label)) end
    end
    MiniPick.set_picker_items(items)
  end)
  local choose = function(item) -- adapted from MiniExtra.pickers.explore
    local path = item.path
    if vim.fn.filereadable(path) == 1 then return MiniPick.default_choose(path) end

    if vim.fn.isdirectory(path) == 1 then -- path does not exist or is a directory
      vim.schedule(function()
        vim.cmd("edit " .. path) -- must schedule, else error
      end)
    end
    return false -- nil and false will stop picker
  end
  local name = for_specific_label and string.format("Visits(%s)", labels[1]) or "Visits(all labels)"
  local show = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end
  local source = { name = name, items = picker_items, show = show, choose = choose }
  local hinted = { enable = true, use_autosubmit = true }
  return MiniPick.start({ source = source, hinted = hinted })
end

H.maintain.show = function(lines, opts)
  local buf_id = vim.api.nvim_create_buf(true, true)
  H.maintain.buf_set_name(buf_id, opts.name)
  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  vim.cmd("tab sbuffer " .. buf_id)
  local tab_num, win_id = vim.api.nvim_tabpage_get_number(0), vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_cursor(win_id, { math.min(opts.n_header + 1, #lines), 0 })

  local delete_buffer = vim.schedule_wrap(function()
    pcall(vim.api.nvim_buf_delete, buf_id, { force = true })
    pcall(function() vim.cmd("tabclose " .. tab_num) end)
    vim.cmd("redraw")
  end)

  local finish = function() -- action to accept
    opts.exec_on_write(buf_id)
    delete_buffer()
  end
  -- - Use `nested` to allow other events (`WinEnter` for 'mini.statusline')
  vim.api.nvim_create_autocmd("BufWriteCmd", { buffer = buf_id, nested = true, callback = finish })

  local cancel_au_id -- action to cancel
  local on_cancel = function(data)
    if tonumber(data.match) ~= win_id then return end
    pcall(vim.api.nvim_del_autocmd, cancel_au_id)
    delete_buffer()
  end
  cancel_au_id = vim.api.nvim_create_autocmd("WinClosed", { nested = true, callback = on_cancel })

  -- Set buffer-local options last (so that user autocmmands could override)
  vim.bo.buftype, vim.bo.filetype, vim.bo.modified = "acwrite", H.maintain_ft, false
end

H.maintain.buf_name_counts = {} -- copied from mini.visits
H.maintain.buf_set_name = function(buf_id, name)
  local n = (H.maintain.buf_name_counts[name] or 0) + 1
  H.maintain.buf_name_counts[name] = n
  local suffix = n == 1 and "" or ("_" .. n)
  vim.api.nvim_buf_set_name(buf_id, name .. suffix)
end

H.is_list_of = function(x, x_name, type_to_test)
  if not vim.islist(x) then return false, string.format("`%s` should be a list.", x_name) end
  for key, value in ipairs(x) do
    if type(value) ~= type_to_test then
      return false, string.format("`%s[%s]` should be a %s.", x_name, vim.inspect(key), type_to_test)
    end
  end
  return true, ""
end

H.is_windows = vim.uv.os_uname().sysname == "Windows_NT" -- copied from mini.visits
H.full_path = function(path) return (vim.fn.fnamemodify(path, ":p"):gsub("/+", "/"):gsub("(.)/$", "%1")) end
if H.is_windows then
  H.full_path = function(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+", "/"):gsub("(.)/$", "%1"))
  end
end

H.short_path = function(path, cwd) -- copied from mini.visits
  cwd = cwd or vim.fn.getcwd()
  -- Ensure `cwd` is treated as directory path (to not match similar prefix)
  cwd = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
  if vim.startswith(path, cwd) then return path:sub(cwd:len() + 1) end
  local res = vim.fn.fnamemodify(path, ":~")
  if H.is_windows then res = res:gsub("\\", "/") end
  return res
end

return VisitsHarpooned
