--          ╭─────────────────────────────────────────────────────────╮
--          │     Aim: Use mini.visits in exactly the same way as     │
--          │                   harpoon or grapple                    │
--          ╰─────────────────────────────────────────────────────────╯

local MV = require("mini.visits")
local H = {} -- helpers
local A = {} -- actions

H.labels = { "core", "dev" }
H.label = H.labels[1]

H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

H.somewhat_unique = function() -- For now, not guaranteed to be unique
  local cwd = vim.fn.getcwd()
  local result = 1
  for i = 1, #cwd do
    result = result + string.byte(cwd, i)
  end
  return result .. "-" .. vim.fn.fnamemodify(cwd, ":t")
end

H.next_label = function()
  local function current_idx()
    for idx, name in ipairs(H.labels) do
      if name == H.label then return idx end
    end
  end
  local idx = current_idx()
  return H.labels[idx == #H.labels and 1 or idx + 1]
end

H.notify_switched_label = function()
  vim.api.nvim_exec_autocmds("User", { pattern = "VisitsSwitchedLabel", modeline = false, data = H.label })
end

H.notify_modified_label = function()
  vim.api.nvim_exec_autocmds("User", { pattern = "VisitsModifiedLabel", modeline = false })
end

H.iterate = function(label, index) -- does not track!
  MiniVisits.iterate_paths("first", nil, {
    filter = label,
    n_times = index,
  })
end

A.next_label = function()
  H.label = H.next_label()
  H.notify_switched_label()
end
A.ui = function() MV.select_path(nil, { filter = H.label }) end
A.select = function(index) H.iterate(H.label, index) end
A.toggle = function()
  local visits = MV.list_paths(nil, { filter = H.label })
  local curpath = vim.fn.expand("%:p")
  if vim.list_contains(visits, curpath) then
    MV.remove_label(H.label)
  else
    MV.register_visit()
    MV.add_label(H.label)
  end
  H.notify_modified_label()
  MV.write_index()
end
A.add_to_dev = function()
  MV.register_visit()
  MV.add_label(H.labels[2])
  H.notify_modified_label()
  MV.write_index()
end

for _, key in ipairs({
  { "<leader>j", A.ui, desc = "Visits ui" },
  { "<leader>a", A.toggle, desc = "Visits +-" },
  --
  { "<c-j>", function() A.select(1) end, desc = "Visit 1" },
  { "<c-k>", function() A.select(2) end, desc = "Visit 2" },
  { "<c-l>", function() A.select(3) end, desc = "Visit 3" },
  { "<c-h>", function() A.select(4) end, desc = "Visit 4" },
  --
  { "<leader>oa", A.add_to_dev, desc = "Visits dev +" },
  { "<leader>oj", A.next_label, desc = "Visits core <-> dev" },
  --   { "<leader>og", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple scopes" },
  --   { "<leader>or", "<cmd>Grapple reset<cr>", desc = "Grapple reset" },
}) do
  H.map(key[1], key[2], key["desc"])
end

MV.setup({
  list = {
    filter = nil,
    sort = function(path_data_arr) -- TODO: Sort on manual orderring?
      table.sort(path_data_arr, function(a, b) return a.path < b.path end)
      return path_data_arr
    end,
  },
  silent = false,
  store = {
    autowrite = false, -- Write manually per action
    normalize = nil, -- TODO: Remove all visits without labels
    path = vim.fn.stdpath("data") .. "/mini-visits-index" .. "-" .. H.somewhat_unique(),
  },
  track = { event = "" }, -- Track manually per action
})
