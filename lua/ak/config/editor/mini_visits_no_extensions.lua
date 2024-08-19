-- Just a POC, showing the core setup needed to use mini.visits like grapple/harpoon.
-- Lacks a UI to add/remove/change files under label, but:
-- 1. Either clear the label from the files using a simple for loop.
-- 2. Add/remove a label on an individual file(toggle)
local Visits = require("mini.visits")

-- Helpers:
local H = {}

H.labels = { "main", "side", "test", "col" }
H.label = H.labels[1]
H.autowrite = false

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
  Visits.iterate_paths("first", nil, { filter = label, n_times = index })
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
  if not H.autowrite then Visits.write_index() end
end

local A = { -- actions:
  ui = function() Visits.select_path(nil, { filter = H.label }) end,
  select = function(index) H.iterate(H.label, index) end,
  switch_context = function() -- alternatively: MiniExtra.pickers.visit_labels
    vim.ui.select(H.labels, { prompt = "Visits switch context" }, function(choice)
      if not choice then return end
      H.label = choice
    end)
  end,
  clear = function()
    local visits = Visits.list_paths(nil, { filter = H.label })
    for _, path in ipairs(visits) do
      Visits.remove_label(H.label, path)
    end
    H.on_change()
  end,
  toggle = function(label)
    local full_path = vim.fn.expand("%:p")
    if vim.list_contains(Visits.list_paths(nil, { filter = label }), full_path) then
      Visits.remove_label(label)
    else
      Visits.register_visit() -- must change "latest" field
      Visits.add_label(label)
    end
    H.on_change()
  end,
}

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
  { "<leader>oj", A.switch_context, desc = "Visits switch context" },
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
