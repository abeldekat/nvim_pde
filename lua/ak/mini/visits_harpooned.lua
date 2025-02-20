-- Replaces grapple.nvim/harpoon. See https://github.com/echasnovski/mini.nvim/discussions/1158
--
-- A label is contextual and provides access to important visits(files/dirs) to work on a task

-- One caveat: Field "latest" applies to a visit, not on individual label
-- Adding a path to a label that is already present in another label might
-- change the order of paths in that other label. I don't consider this a problem

-- This setup works with one visit index file per project dir and one global visit index
-- Tested to also operate correctly when using MiniMisc.setup_auto_root: vim.fn.changedir on BufEnter.
--
-- Requirements:
-- 1. MiniPick active
-- 2. Restore cursor functionality. See MiniMisc.setup_restore_cursor
-- 3. MiniVisits not active. Its setup is invoked here

local VisitsHarpooned = {}
local H = {} -- helper
local Api = {} -- handle calls to MiniVisits regarding labels, cwd and store_path

VisitsHarpooned.setup = function(config)
  _G.VisitsHarpooned = VisitsHarpooned
  config = H.setup_config(config)
  H.apply_config(config)
  H.create_autocommands()

  H.minivisits_setup()
  H.current_label = config.start_label
  if config.global_label ~= "" then
    Api.overrides[config.global_label] = {
      store_path = string.format("%s/%s", H.store_dir, "index-global"),
    }
  end
end

VisitsHarpooned.config = {
  labels = { "core", "oth", "glo" }, -- must contain one label
  start_label = "core", -- required
  uncategorized_label = "oth", -- uncategorized, disable with ""
  global_label = "glo", -- global, used to transfer visits, disable with ""
  mappings = { -- disable a mapping with "":
    ui_all = "<leader>j",
    ui = "<leader>ol",
    toggle = "<leader>a",
    change_active_label = "<leader>oj",
    add_to_uncategorized = "<leader>oa",
    copy_from_global = "<leader>oc",
    maintain = "<leader>om",
    clear = "<leader>or",
    selects = { "ma", "ms", "md", "mf" }, -- { "<c-j>", "<c-k>", "<c-l>", "<c-h>" }
  },
  picker_hints_on_change_active_label = { "a", "s", "d", "f" }, -- predictable picker hints
}

VisitsHarpooned.get_start_label = function() return H.get_config().start_label end

VisitsHarpooned.list_paths = function(label) return Api.list_paths(label) end

VisitsHarpooned.full_path_of_current_buffer = function()
  local ft = vim.bo.ft
  if ft and ft == "minifiles" then
    local curpath = vim.fs.dirname((MiniFiles.get_fs_entry() or {}).path)
    if curpath == nil then return vim.notify("Cursor is not on valid entry") end

    return curpath
  end
  return vim.fn.expand("%:p")
end

-- Helper ================================================================

H.default_config = vim.deepcopy(VisitsHarpooned.config)
H.store_dir = string.format("%s/%s", vim.fn.stdpath("data"), "visits_harpooned")
H.maintain_ft = "visits-harpooned-maintain"
H.current_label = nil

H.is_list_of = function(x, x_name, type_to_test)
  if not vim.islist(x) then return false, string.format("`%s` should be a list.", x_name) end
  for key, value in ipairs(x) do
    if type(value) ~= type_to_test then
      return false, string.format("`%s[%s]` should be a %s.", x_name, vim.inspect(key), type_to_test)
    end
  end
  return true, ""
end

H.setup_config = function(config)
  vim.validate({
    MiniVisits = { MiniVisits, "nil" }, -- mini.visits should not be active
    MiniPick = { MiniPick, "table" },
    config = { config, "table" },
  })
  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

  vim.validate({
    labels = { config.labels, "table" },
    start_label = { config.start_label, "string" },
    uncategorized_label = { config.uncategorized_label, "string" },
    global_label = { config.global_label, "string" },
    mappings = { config.mappings, "table" },
    picker_hints_on_change_active_label = { config.mappings, "table" },
  })
  vim.validate({
    labels = { #config.labels, function(val) return val > 0 end, "at least 1 label" },
    ["mappings.ui_all"] = { config.mappings.ui_all, "string" },
    ["mappings.ui"] = { config.mappings.ui, "string" },
    ["mappings.toggle"] = { config.mappings.toggle, "string" },
    ["mappings.change_active_label"] = { config.mappings.change_active_label, "string" },
    ["mappings.add_to_uncategorized"] = { config.mappings.add_to_uncategorized, "string" },
    ["mappings.copy_from_global"] = { config.mappings.copy_from_global, "string" },
    ["mappings.maintain"] = { config.mappings.maintain, "string" },
    ["mappings.clear"] = { config.mappings.clear, "string" },
    ["mappings.selects"] = { config.mappings.selects, "table" },
  })
  vim.validate({
    ["labels"] = { config.labels, function(x) return H.is_list_of(x, "labels", "string") end },
    ["mappings.selects"] = {
      config.mappings.selects,
      function(x) return H.is_list_of(x, "mappings.selects", "string") end,
    },
    ["picker_hints_on_change_active_label"] = {
      config.picker_hints_on_change_active_label,
      function(x) return H.is_list_of(x, "picker_hints_on_change_active_label", "string") end,
    },
  })
  return config
end

H.apply_config = function(config)
  VisitsHarpooned.config = config
  local keys = config.mappings

  -- -- Apply mappings
  H.map("n", keys.ui_all, function() H.pick_visits_by_labels(config.labels) end, { desc = "Visits pick all" })
  H.map("n", keys.ui, function() H.pick_visits_by_labels({ H.current_label }) end, { desc = "Visits pick active" })
  H.map("n", keys.toggle, H.toggle, { desc = "Visits toggle" })
  H.map("n", keys.change_active_label, H.pick_labels, { desc = "Visits change active label" })

  local unc_label = config.uncategorized_label
  local unc_desc = { desc = "Visits add to uncategorized" }
  H.map("n", keys.add_to_uncategorized, function() H.add(unc_label) end, unc_desc)
  unc_desc = { desc = "Visits copy from global" }
  H.map("n", keys.copy_from_global, function() H.copy_from_global(unc_label) end, unc_desc)

  H.map("n", keys.maintain, function() H.maintain(H.current_label) end, { desc = "Visits maintain" })
  H.map("n", keys.clear, H.clear_visits, { desc = "Visits clear" })

  for i = 1, #keys.selects do
    H.map("n", keys.selects[i], function()
      local ft = vim.bo.ft
      if ft and ft == "minifiles" then MiniFiles.close() end

      Api.iterate(H.current_label, i)
    end, { desc = "Visit " .. i })
  end
end

H.get_config = function()
  -- No buffer override: vim.b.akminivisitsharpooned or {}
  -- No config arg to merge
  -- return vim.tbl_deep_extend("force", VisitsHarpoonedLine.config or {}, config or {})
  return VisitsHarpooned.config
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

  au("User", "MiniFilesExplorerClose", function(ev) -- No BufEnter on close
    vim.schedule(
      function() vim.api.nvim_exec_autocmds("User", { pattern = "VisitsHarpoonedModified", modeline = false }) end
    )
  end)
end

H.map = function(mode, lhs, rhs, opts)
  if lhs == "" then return end
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Copied from mini.visits
H.is_windows = vim.uv.os_uname().sysname == "Windows_NT"

-- Copied from mini.visits
H.full_path = function(path) return (vim.fn.fnamemodify(path, ":p"):gsub("/+", "/"):gsub("(.)/$", "%1")) end
if H.is_windows then
  H.full_path = function(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+", "/"):gsub("(.)/$", "%1"))
  end
end

-- Copied from mini.visits
H.short_path = function(path, cwd)
  cwd = cwd or vim.fn.getcwd()
  -- Ensure `cwd` is treated as directory path (to not match similar prefix)
  cwd = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
  if vim.startswith(path, cwd) then return path:sub(cwd:len() + 1) end
  local res = vim.fn.fnamemodify(path, ":~")
  if H.is_windows then res = res:gsub("\\", "/") end
  return res
end

H.clear_visits = function()
  Api.remove_label_from_visits(H.current_label)
  Api.on_change(H.current_label)
end

H.remove = function(label, full_path)
  full_path = full_path or VisitsHarpooned.full_path_of_current_buffer()
  Api.remove_label_from_path(label, full_path)
  Api.on_change(label)
end

H.add = function(label, full_path)
  full_path = full_path or VisitsHarpooned.full_path_of_current_buffer()
  Api.register_visit(full_path) -- must update "latest" field
  Api.add_label(label, full_path)
  Api.on_change(label)
end

H.toggle = function()
  local full_path = VisitsHarpooned.full_path_of_current_buffer()
  if vim.list_contains(Api.list_paths(H.current_label), full_path) then
    H.remove(H.current_label, full_path)
  else
    H.add(H.current_label, full_path)
  end
end

H.change_active_label = function(from_label, to_label)
  Api.ensure_index(from_label, to_label)
  H.current_label = to_label
  vim.api.nvim_exec_autocmds(
    "User",
    { pattern = "VisitsHarpoonedChangedActiveLabel", modeline = false, data = H.current_label }
  )
end

H.copy_from_global = function(local_label)
  local global_label = H.get_config().global_label

  if H.current_label ~= global_label then Api.ensure_index(local_label, global_label) end
  local global_visits = Api.list_paths(global_label)
  H.change_active_label(global_label, local_label)

  local to_update = vim.list_extend(Api.list_paths(local_label), global_visits)
  H.batch_update(to_update, local_label)
end

H.batch_update = function(paths_from_user, label)
  Api.remove_label_from_visits(label)

  local index = MiniVisits.get_index()
  index = vim.tbl_isempty(index) and { [Api.dummy_cwd] = {} } or index
  local time = os.time()
  local for_cwd = index[Api.dummy_cwd]
  for ind, path in ipairs(paths_from_user) do -- os.time: in seconds
    local data = for_cwd[path] or { latest = 0, count = 0 }
    data.latest = time + ind -- ensure 1 second difference with previous
    data.labels = data.labels and data.labels or {}
    data.labels[label] = true -- add the label
    for_cwd[path] = data
  end
  MiniVisits.set_index(index)
  Api.on_change(label)
end

-- Copied from mini.visits, only needed for H.maintain_show
H.buf_name_counts = {}
H.buf_set_name = function(buf_id, name)
  local n = (H.buf_name_counts[name] or 0) + 1
  H.buf_name_counts[name] = n
  local suffix = n == 1 and "" or ("_" .. n)
  vim.api.nvim_buf_set_name(buf_id, name .. suffix)
end

H.maintain_show = function(lines, opts) -- only needed for maintain_show
  local buf_id = vim.api.nvim_create_buf(true, true)
  H.buf_set_name(buf_id, opts.name)
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
  vim.bo.buftype, vim.bo.filetype, vim.bo.modified = "acwrite", "visits-harpooned-maintain", false
end

H.maintain = function(label) -- mini.deps, H.update_feedback_confirm, copied and modified
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
  end, Api.list_paths(label))
  vim.list_extend(report, items)

  local finish = function(buf_id)
    local paths = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf_id, n_header, -1, false)) do
      table.insert(paths, H.full_path(l)) -- update full paths...
    end
    H.batch_update(paths, label)
  end
  local name = string.format("visits-ak://maintain-%s", label)
  H.maintain_show(report, { name = name, exec_on_write = finish, n_header = n_header })
end

H.pick_labels = function()
  local conf = H.get_config()
  local name = "Visits change active label"
  local picker_items = conf.labels
  local choose = function(item) H.change_active_label(H.current_label, item) end
  local source = { name = name, items = picker_items, choose = choose }
  local hinted = { enable = true, use_autosubmit = true, chars = conf.picker_hints_on_change_active_label }
  return MiniPick.start({ source = source, hinted = hinted })
end

H.pick_visits_by_labels = function(labels) -- a customized Extra.pickers.visit_paths
  -- Copied from mini.extra:
  -- Not copied: H.full_path, H.normalize_path, H.is_windows
  local short_path = function(path, cwd)
    cwd = cwd or vim.fn.getcwd()
    -- Ensure `cwd` is treated as directory path (to not match similar prefix)
    cwd = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
    return vim.startswith(path, cwd) and path:sub(cwd:len() + 1) or vim.fn.fnamemodify(path, ":~")
  end

  local paths_to_items = function(paths, label)
    return vim.tbl_map(function(visit_path)
      local path_path = visit_path -- needed, otherwise files outside cwd are not opened
      local text_path = short_path(visit_path)
      return { path = path_path, text = string.format(" %-6s %s", label, text_path) }
    end, paths)
  end
  local picker_items = vim.schedule_wrap(function()
    local items = {}
    for _, label in ipairs(labels) do
      local paths = Api.list_paths(label)
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
  local name = #labels > 1 and "Visits(all labels)" or string.format("Visits(%s)", labels[1])
  local show = function(buf_id, items, query) MiniPick.default_show(buf_id, items, query, { show_icons = true }) end
  local source = { name = name, items = picker_items, show = show, choose = choose }
  local hinted = { enable = true, use_autosubmit = true }
  return MiniPick.start({ source = source, hinted = hinted })
end

H.minivisits_setup = function()
  local Visits = require("mini.visits")
  local gen_normalize_default_labels_only = function() -- keep visits with labels, remove others
    local normalize_default = Visits.gen_normalize.default()
    return function(index)
      index = normalize_default(index)
      for _, paths in pairs(index) do
        for path, path_data in pairs(paths) do
          if not path_data.labels then paths[path] = nil end
        end
      end
      return index
    end
  end
  local project_store_path = function() -- Good enough, but not guaranteed to be unique
    local result = string.format("%s/%s", H.store_dir, "index")
    local cwd = vim.fn.getcwd()
    local cwd_to_number = 1
    for i = 1, #cwd do -- transform cwd to a number
      cwd_to_number = cwd_to_number + string.byte(cwd, i)
    end
    return string.format("%s-%d-%s", result, cwd_to_number, vim.fn.fnamemodify(cwd, ":t"))
  end
  Visits.setup({
    list = {
      sort = function(path_data_arr) -- only on recency
        table.sort(path_data_arr, function(a, b) return a.latest < b.latest end)
        return path_data_arr
      end,
    },
    silent = true, -- false,
    store = {
      autowrite = false, -- write visits on change
      normalize = gen_normalize_default_labels_only(),
      path = project_store_path(),
    },
    track = { event = "" }, -- add visits programatically
  })
end

-- Visits Api ================================================================
-- Handle calls to MiniVisits regarding labels, cwd and store_path

Api.default_store_path = nil -- nil means: config.store.path
Api.all_cwd = ""
Api.all_paths = ""
Api.overrides = {}

-- The index file is stored per project dir, so the 'cwd' as key can always be the same
-- Another benefit: A "cd" does not disrupt the workflow
-- All visits are always added to this 'cwd' key, preventing visits for the same paths
-- to be registered in multiple places.
Api.dummy_cwd = string.format("%s", vim.fn.expand("~")) -- guaranteed to exist

Api.remove_label_from_visits = function(label) MiniVisits.remove_label(label, Api.all_paths, Api.all_cwd) end

Api.ensure_index = function(oldlabel, newlabel) -- use correct index file for newlabel
  local old_override, new_override = Api.overrides[oldlabel], Api.overrides[newlabel]
  if not (old_override or new_override) then return end

  MiniVisits.set_index({}) -- prevent merge on read
  local store_path = new_override and new_override.store_path or Api.default_store_path
  MiniVisits.set_index(MiniVisits.read_index(store_path) or {})
end

Api.on_change = function(label)
  vim.api.nvim_exec_autocmds("User", { pattern = "VisitsHarpoonedModified", modeline = false })
  Api.write_index(label)
end

-- MiniVisits api, write to correct store path:

Api.write_index = function(label)
  local override = Api.overrides[label]
  MiniVisits.write_index(override and override.store_path or Api.default_store_path)
end

-- MiniVisits api, add to correct cwd:

Api.register_visit = function(full_path) MiniVisits.register_visit(full_path, Api.dummy_cwd) end

Api.add_label = function(label, full_path) MiniVisits.add_label(label, full_path, Api.dummy_cwd) end

-- MiniVisits api, retrieve or remove from correct cwd:

Api.list_paths = function(label) return MiniVisits.list_paths(Api.all_cwd, { filter = label }) end
Api.iterate = function(label, index)
  local it_opts = { filter = label, n_times = index }
  MiniVisits.iterate_paths("first", Api.all_cwd, it_opts)
end
Api.select_path = function(label) return MiniVisits.select_path(Api.all_cwd, { filter = label }) end
Api.remove_label_from_path = function(label, full_path) MiniVisits.remove_label(label, full_path, Api.all_cwd) end

return VisitsHarpooned
