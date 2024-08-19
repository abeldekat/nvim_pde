-- Replaces grapple.nvim...

-- Approach:
--
-- A label provides access to important visits(files/dirs) to work on a task.
-- As such, a label is contextual. There can be multiple labels.
-- For the active label, the first four files are on ctrl-{jklh}
--
-- <leader>a toggles the current label on a visit.
-- There is a generic 'col'(collection) label for which files can always be toggled using <leader>oa
--
-- Pick.registry.visits_by_label provides fast sorted access to all labeled visits.
-- No need to change the current context.
--
-- See also:
-- 1. ak.config.editor: mini_pick and mini_pick_labeled
-- 2. ak.config.ui: mini_statusline and visitsline
-- 3. ak.util.labels
-- 4. ak.config.autocmmands

-- One caveat: Field "latest" applies on visit, not on individual label
-- Adding a path to a label that is already present in another label might
-- change the order of paths in that other label. I don't consider this a problem.

-- This implementation is strictly per project-dir.
-- A branch context is not supported. Use worktrees instead
-- A global context is not needed. Use recent files, and add the file to one of the labels

local Visits = require("mini.visits")
local Utils = require("ak.util")

-- Helpers:

local H = {}

H.labels = Utils.labels.visits
H.label = H.labels[1]
H.autowrite = false

-- Copied, needed for H.maintain_show
H.buf_name_counts = {}
-- Copied
H.buf_set_name = function(buf_id, name)
  local n = (H.buf_name_counts[name] or 0) + 1
  H.buf_name_counts[name] = n
  local suffix = n == 1 and "" or ("_" .. n)
  vim.api.nvim_buf_set_name(buf_id, name .. suffix)
end
-- Copied
H.full_path = function(path) return (vim.fn.fnamemodify(path, ":p"):gsub("/+", "/"):gsub("(.)/$", "%1")) end
if H.is_windows then
  H.full_path = function(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+", "/"):gsub("(.)/$", "%1"))
  end
end
-- Copied
H.short_path = function(path, cwd)
  cwd = cwd or vim.fn.getcwd()
  -- Ensure `cwd` is treated as directory path (to not match similar prefix)
  cwd = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
  if vim.startswith(path, cwd) then return path:sub(cwd:len() + 1) end
  local res = vim.fn.fnamemodify(path, ":~")
  if H.is_windows then res = res:gsub("\\", "/") end
  return res
end

H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

-- TODO: Good enough, but not guaranteed to be unique
H.somewhat_unique_project_name = function()
  local result = string.format("%s/%s", vim.fn.stdpath("data"), "mini-visits-index")
  local cwd = vim.fn.getcwd()
  local cwd_to_number = 1
  for i = 1, #cwd do -- transform cwd to a number
    cwd_to_number = cwd_to_number + string.byte(cwd, i)
  end
  return string.format("%s-%d-%s", result, cwd_to_number, vim.fn.fnamemodify(cwd, ":t"))
end

H.iterate = function(label, index) -- does not track!
  Visits.iterate_paths("first", nil, {
    filter = label,
    n_times = index,
  })
end

H.sort = function(path_data_arr) -- only on recency
  table.sort(path_data_arr, function(a, b) return a.latest < b.latest end)
  return path_data_arr
end

H.gen_normalize = function() -- keep visits with labels, remove others
  local default = Visits.gen_normalize.default()
  return function(index)
    index = default(index)
    for cwd, paths in pairs(index) do
      for path, data in pairs(paths) do
        if not data.labels then index[cwd][path] = nil end
      end
    end
    return index
  end
end

H.on_change = function()
  vim.api.nvim_exec_autocmds("User", { pattern = "VisitsModified", modeline = false })
  if not H.autowrite then Visits.write_index() end
end

H.maintain_finish = function(paths_from_user, label)
  -- KISS: Remove label from all paths in cwd
  for _, path in ipairs(Visits.list_paths(nil, { filter = label })) do
    Visits.remove_label(label, path)
  end

  -- KISS: Add label to paths in the order the user provided
  local index = Visits.get_index() or {}
  local cwd_tbl = index[vim.fn.getcwd()] or {}
  for ind, path in ipairs(paths_from_user) do -- os.time: in seconds
    local data = cwd_tbl[path] or { count = 0, latest = 0 }
    data.latest = os.time() + ind -- ensure 1 second difference with previous
    data.labels = data.labels and data.labels or {}
    data.labels[label] = true -- add the label
    cwd_tbl[path] = data
  end
  Visits.set_index(index)
  H.on_change()
end

H.maintain_show = function(lines, opts)
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
  vim.bo.buftype, vim.bo.filetype, vim.bo.modified = "acwrite", "visits-label-maintain", false
end

H.maintain = function(label)
  local report = {
    string.format("Maintain visits that are labeled with [%s]", label),
    "",
    string.format("1. Remove lines to remove [%s]", label),
    string.format("2. Reorder lines to define the order of files in [%s]", label),
    "3. Otherwise, prefer toggle visits(leader a)",
    "",
    "Write to save, quit to cancel:",
    "",
  }
  local n_header = #report
  local items = vim.tbl_map(function(full_path) -- show short paths
    return H.short_path(full_path)
  end, Visits.list_paths(nil, { filter = label }))
  vim.list_extend(report, items) -- show short paths

  local finish = function(buf_id)
    local paths = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf_id, n_header, -1, false)) do
      table.insert(paths, H.full_path(l)) -- update full paths
    end
    H.maintain_finish(paths, label)
  end
  local name = string.format("visits-ak://maintain-%s", label)
  H.maintain_show(report, { name = name, exec_on_write = finish, n_header = n_header })
end

-- Actions:

local A = {
  ui = function() Visits.select_path(nil, { filter = H.label }) end,
  select = function(index) H.iterate(H.label, index) end,
  switch_context = function() -- alternatively: MiniExtra.pickers.visit_labels
    vim.ui.select(H.labels, { prompt = "Visits switch context" }, function(choice)
      if not choice then return end
      H.label = choice
      vim.api.nvim_exec_autocmds("User", { pattern = "VisitsSwitchedContext", modeline = false, data = H.label })
    end)
  end,
  maintain = function() H.maintain(H.label) end,
  clear = function()
    local visits = Visits.list_paths(nil, { filter = H.label })
    for _, path in ipairs(visits) do
      Visits.remove_label(H.label, path)
    end
    H.on_change()
  end,
  toggle = function(label)
    local full_path = Utils.full_path_of_current_buffer()
    if vim.list_contains(Visits.list_paths(nil, { filter = label }), full_path) then
      Visits.remove_label(label, full_path)
    else
      Visits.register_visit(full_path) -- must change "latest" field
      Visits.add_label(label, full_path)
    end
    H.on_change()
  end,
}

-- Setup:

for _, key in ipairs({
  -- Most important keys:
  { "<leader>j", A.ui, desc = "Visits ui" },
  { "<leader>a", function() A.toggle(H.label) end, desc = "Visits toggle" },

  -- Open indexed file in current label:
  { "<c-j>", function() A.select(1) end, desc = "Visit 1" },
  { "<c-k>", function() A.select(2) end, desc = "Visit 2" },
  { "<c-l>", function() A.select(3) end, desc = "Visit 3" },
  { "<c-h>", function() A.select(4) end, desc = "Visit 4" },

  -- Other actions:
  { "<leader>oa", function() A.toggle(H.labels[#H.labels]) end, desc = "Visits 'col' toggle" },
  { "<leader>oj", A.switch_context, desc = "Visits switch context" },
  { "<leader>om", A.maintain, desc = "Visits maintain" },
  { "<leader>or", A.clear, desc = "Visits clear" },
}) do
  H.map(key[1], key[2], key["desc"])
end

Visits.setup({
  list = { sort = H.sort }, -- only on recency
  silent = true, -- false,
  store = {
    autowrite = H.autowrite, -- if false, write on action
    normalize = H.gen_normalize(), -- remove visits without labels
    path = H.somewhat_unique_project_name(), -- store per project dir
  },
  track = { event = "" }, -- visits are added programmatically as a result of actions
})
