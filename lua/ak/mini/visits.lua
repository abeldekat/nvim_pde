-- By default, MiniVisits uses one single file to store all visits.
-- Its internal representation is flushed to that file when Neovim is exited.
-- As a consequence, when the user has multiple editors open, the last process
-- to close 'wins', whereby visit registrations and label modifications are lost.
-- Solution: Use config.store.path, in order to work with a single storage file per project.
--
-- In this config, 'all visits' only refers to the visits collected between
-- the opening and closing of Neovim in a project.
-- To inspect the entire history, the user can pick from `v:oldfiles`.
--
-- Note that the visits returned when querying for a label are sorted by recency
-- and don't maintain a fixed position over time. Hotkeys to each individual element
-- are less usefull. However, internal `akextra.pick_hinted` with `use_autosubmit` provides
-- fast and predictable access. Enter is not required and the labels are positioned.

local start_label = 'core'

local make_project_store_path = function() -- Good enough, make unique path
  local store_dir = string.format('%s/%s', vim.fn.stdpath('data'), 'visits')
  local result = string.format('%s/%s', store_dir, 'index')
  local cwd = vim.fn.getcwd()
  local cwd_to_number = 0
  for i = 1, #cwd do -- transform cwd to a number
    cwd_to_number = cwd_to_number + string.byte(cwd, i)
  end
  return string.format('%s-%d-%s', result, cwd_to_number, vim.fn.fnamemodify(cwd, ':t'))
end

local list_labels = function()
  local labels = vim.tbl_filter(function(label) return label ~= start_label end, MiniVisits.list_labels('', ''))
  table.insert(labels, 1, start_label) -- ensure start label at first position
  return labels
end

local visits_choose_current_label = function()
  vim.ui.select(list_labels(), {}, function(selected)
    if not selected then return end
    Config.visits_label = selected
  end)
end

require('mini.visits').setup({ silent = true, store = { path = make_project_store_path() } })
Config.visits_label = start_label
Config.visits_choose_current = visits_choose_current_label
