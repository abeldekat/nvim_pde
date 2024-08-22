-- Replaces grapple.nvim/harpoon.Approach:
--
-- A label provides access to important visits(files/dirs) to work on a task
-- As such, a label is contextual. There can be multiple labels
-- The first four files of the active label are on ctrl-{jklh}
--
-- <leader>a toggles the current label on a visit
-- Pick.registry.visits_by_label provides fast sorted access to all labeled visits
-- No need to change the current context
--
-- See also:
-- 1. ak.util.visits
-- 2. ak.config.ui: mini_statusline and visitsline
-- 3. ak.config.editor: mini_pick and mini_pick_labeled
-- 4. ak.config.autocommands

-- One caveat: Field "latest" applies on visit, not on individual label
-- Adding a path to a label that is already present in another label might
-- change the order of paths in that other label. I don't consider this a problem

-- This setup works with one visit index file per project dir
-- The global label uses a separate file and a fixed dummy cwd, in order to
-- prevent the same paths to be stored in multiple cwd. In this setup,
-- those are not useful.
-- Tested to also operate correctly when using MiniMisc.setup_auto_root:
-- vim.fn.changedir on BufEnter.

local Utils = require("ak.util")
local CustomVisits = Utils.visits

local H = {} -- Helpers
local HC = {} -- Copied from mini.visits

HC.is_windows = vim.loop.os_uname().sysname == "Windows_NT"
HC.full_path = function(path) return (vim.fn.fnamemodify(path, ":p"):gsub("/+", "/"):gsub("(.)/$", "%1")) end
if HC.is_windows then
  HC.full_path = function(path)
    return (vim.fn.fnamemodify(path, ":p"):gsub("\\", "/"):gsub("/+", "/"):gsub("(.)/$", "%1"))
  end
end
HC.short_path = function(path, cwd)
  cwd = cwd or vim.fn.getcwd()
  -- Ensure `cwd` is treated as directory path (to not match similar prefix)
  cwd = cwd:sub(-1) == "/" and cwd or (cwd .. "/")
  if vim.startswith(path, cwd) then return path:sub(cwd:len() + 1) end
  local res = vim.fn.fnamemodify(path, ":~")
  if HC.is_windows then res = res:gsub("\\", "/") end
  return res
end

H.label = CustomVisits.start_label

H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

H.project_store_path = function() -- Good enough, but not guaranteed to be unique
  local result = string.format("%s/%s/%s", vim.fn.stdpath("data"), "mini_visits", "index")
  local cwd = vim.fn.getcwd()
  local cwd_to_number = 1
  for i = 1, #cwd do -- transform cwd to a number
    cwd_to_number = cwd_to_number + string.byte(cwd, i)
  end
  return string.format("%s-%d-%s", result, cwd_to_number, vim.fn.fnamemodify(cwd, ":t"))
end

H.maintain_finish = function(paths_from_user, label)
  CustomVisits.remove_label_from_visits(label)

  local index = MiniVisits.get_index()
  local time = os.time()
  for _, paths in pairs(index) do
    for ind, path in ipairs(paths_from_user) do -- os.time: in seconds
      local data = paths[path] -- only for existing paths
      if data then
        data.latest = time + ind -- ensure 1 second difference with previous
        data.labels = data.labels and data.labels or {}
        data.labels[label] = true -- add the label
        paths[path] = data
      end
    end
  end
  MiniVisits.set_index(index)
end

HC.buf_name_counts = {}
HC.buf_set_name = function(buf_id, name) -- only needed for maintain_show
  local n = (HC.buf_name_counts[name] or 0) + 1
  HC.buf_name_counts[name] = n
  local suffix = n == 1 and "" or ("_" .. n)
  vim.api.nvim_buf_set_name(buf_id, name .. suffix)
end
H.maintain_show = function(lines, opts) -- only needed for maintain_show
  local buf_id = vim.api.nvim_create_buf(true, true)
  HC.buf_set_name(buf_id, opts.name)
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

H.maintain = function(label) -- mini.deps, H.update_feedback_confirm, copied and modified
  local report = {
    string.format("Maintain visits that are labeled with [%s]", label),
    "",
    string.format("1. Remove lines to remove [%s]", label),
    string.format("2. Reorder lines to define the order of files in [%s]", label),
    "3. Otherwise, use toggle visits(leader a)",
    "",
    "Write to save, quit to cancel:",
    "",
  }
  local n_header = #report
  local items = vim.tbl_map(function(full_path) -- show short paths
    return HC.short_path(full_path)
  end, CustomVisits.list_paths(label))
  vim.list_extend(report, items)

  local finish = function(buf_id)
    local paths = {}
    for _, l in ipairs(vim.api.nvim_buf_get_lines(buf_id, n_header, -1, false)) do
      table.insert(paths, HC.full_path(l)) -- update full paths
    end
    H.maintain_finish(paths, label)
    H.on_change(label)
  end
  local name = string.format("visits-ak://maintain-%s", label)
  H.maintain_show(report, { name = name, exec_on_write = finish, n_header = n_header })
end

H.on_change = function(label)
  vim.api.nvim_exec_autocmds("User", { pattern = "VisitsModified", modeline = false })
  CustomVisits.write_index(label)
end

-- Actions:
local A = {
  ui = function() CustomVisits.select_path(H.label) end,
  select = function(index) CustomVisits.iterate(H.label, index) end,
  switch_context = function()
    vim.ui.select(CustomVisits.labels, { prompt = "Visits switch context" }, function(choice)
      if not choice then return end

      local oldlabel = H.label
      H.label = choice
      CustomVisits.ensure_index(oldlabel, H.label)
      vim.api.nvim_exec_autocmds("User", { pattern = "VisitsSwitchedContext", modeline = false, data = H.label })
    end)
  end,
  maintain = function() H.maintain(H.label) end,
  clear = function()
    CustomVisits.remove_label_from_visits(H.label)
    H.on_change(H.label)
  end,
  toggle = function(label)
    local full_path = Utils.full_path_of_current_buffer() -- accounts for oil
    if vim.list_contains(CustomVisits.list_paths(label), full_path) then
      CustomVisits.remove_label(label, full_path)
    else
      CustomVisits.register_visit(full_path, label) -- must update "latest" field
      CustomVisits.add_label(label, full_path)
    end
    H.on_change(label)
  end,
  add_to_generic = function() CustomVisits.add_label(CustomVisits.generic_label) end,
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
  { "<leader>oa", function() A.add_to_generic() end, desc = "Visits add to generic label" },
  { "<leader>oj", A.switch_context, desc = "Visits switch context" },
  { "<leader>om", A.maintain, desc = "Visits maintain" },
  { "<leader>or", A.clear, desc = "Visits clear" },
}) do
  H.map(key[1], key[2], key["desc"])
end

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
    path = H.project_store_path(),
  },
  track = { event = "" }, -- add visits programatically
})
