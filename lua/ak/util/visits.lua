-- Encapsulate the "label" part of mini.visits

local api_default_store_path = nil -- config.store.path
local api_all_cwd = ""
local api_all_paths = ""

-- The index file is stored per project dir, so the 'cwd' as key can always be the same
-- Another benefit: A "cd" does not disrupt the workflow
-- All visits are always added to this 'cwd' key, preventing visits for the same paths
-- to be registered in multiple places.
local dummy_cwd = string.format("%s", vim.fn.expand("~")) -- guaranteed to exist

local start_label, oth_label, global_label = "core", "oth", "glo"

local overrides = {
  [global_label] = {
    store_path = string.format("%s/%s/%s", vim.fn.stdpath("data"), "mini_visits", "index-global"),
  },
}

-- CustomVisits public:

---@class ak.util.visits
local M = {}

M.labels = {
  start_label, -- Main task context, first label to use
  "side", -- Side task context
  "test", -- Testing context
  oth_label, -- other files of interest, concept: "Create visits manually"
  global_label, -- shared between projects
}
M.start_label = start_label
M.oth_label = oth_label

M.remove_label_from_visits = function(label) MiniVisits.remove_label(label, api_all_paths, api_all_cwd) end

M.ensure_index = function(oldlabel, newlabel) -- use correct index file for newlabel
  local old_override, new_override = overrides[oldlabel], overrides[newlabel]
  if not (old_override or new_override) then return end

  MiniVisits.set_index({}) -- prevent merge on read
  local store_path = new_override and new_override.store_path or api_default_store_path
  MiniVisits.set_index(MiniVisits.read_index(store_path) or {})
end

-- MiniVisits api, controlling store path based on label when writing:

M.write_index = function(label)
  local override = overrides[label]
  MiniVisits.write_index(override and override.store_path or api_default_store_path)
end

-- MiniVisits api, controlling cwd when adding:

M.register_visit = function(full_path) MiniVisits.register_visit(full_path, dummy_cwd) end

M.add_label = function(label, full_path) MiniVisits.add_label(label, full_path, dummy_cwd) end

-- MiniVisits api, controlling all cwd in index file when retrieving or removing:

local cwd_to_use = api_all_cwd
M.list_paths = function(label) return MiniVisits.list_paths(cwd_to_use, { filter = label }) end
M.iterate = function(label, index)
  local it_opts = { filter = label, n_times = index }
  MiniVisits.iterate_paths("first", cwd_to_use, it_opts)
end
M.select_path = function(label) return MiniVisits.select_path(cwd_to_use, { filter = label }) end
M.remove_label = function(label, full_path) MiniVisits.remove_label(label, full_path, cwd_to_use) end

return M
