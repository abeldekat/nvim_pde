-- Encapsulate the "label" part of mini.visits

local api_default_store_path = nil -- config.store.path
local api_current_cwd = nil -- current cwd, vim.fn.getcwd
local api_all_cwd = ""
local api_all_paths = ""

local start_label, generic_label, global_label = "main", "gen", "glo"

local overrides = {
  [global_label] = {
    cwd = string.format("%s", vim.fn.expand("~")), -- a dummy cwd, guaranteed to exist
    store_path = string.format("%s/%s/%s", vim.fn.stdpath("data"), "mini_visits", "index-global"),
  },
}

local calc_cwd_on_add = function(label)
  local override = overrides[label]
  return override and override.cwd or api_current_cwd -- api_all_cwd not allowed!
end

-- CustomVisits public:

---@class ak.util.visits
local M = {}

M.labels = {
  start_label, -- Main task context, first label to use
  "side", -- Side task context
  "test", -- Testing context
  generic_label, -- other files of interest, concept: "Create visits manually"
  global_label, -- shared between projects
}
M.start_label = start_label
M.generic_label = generic_label

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

-- MiniVisits api, controlling cwd based on label when adding:

M.register_visit = function(full_path, label) MiniVisits.register_visit(full_path, calc_cwd_on_add(label)) end

M.add_label = function(label, full_path) MiniVisits.add_label(label, full_path, calc_cwd_on_add(label)) end

-- MiniVisits api, controlling all cwd in index file when retrieve or removing:

local cwd_to_use = api_all_cwd
M.list_paths = function(label) return MiniVisits.list_paths(cwd_to_use, { filter = label }) end
M.iterate = function(label, index)
  local it_opts = { filter = label, n_times = index }
  MiniVisits.iterate_paths("first", cwd_to_use, it_opts)
end
M.select_path = function(label) return MiniVisits.select_path(cwd_to_use, { filter = label }) end
M.remove_label = function(label, full_path) MiniVisits.remove_label(label, full_path, cwd_to_use) end

return M
