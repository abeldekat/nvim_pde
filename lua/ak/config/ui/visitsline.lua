local M = {}
local Visits = require("mini.visits")
local Utils = require("ak.util")

local label_name = Utils.labels.visits[1]
local is_current_buffer_labeled = false
local cached_line
local notify_cb

local opts = {
  -- icon = "󰛢", -- nf-md-hook  -- f06e2 -- nerdfont -- area plane a
  icon = "󰖃", -- nf-md-walk  -- f0583
  label_names = {}, -- label_name override for display
  max_slots = 4,
  inactive = "%s",
  active = function()
    is_current_buffer_labeled = true
    return "[%s]"
  end,
  sep = "·",
  more_marks = "…", -- #slots < #visits, horizontal elipsis
}

local function produce()
  local visits = Visits.list_paths(nil, { filter = label_name }) or {}
  is_current_buffer_labeled = false

  local label = opts.label_names[label_name] or string.format("%s:", label_name)
  local header = string.format("%s%s%s", opts.icon, label == "" and "" or " ", label)

  local nr_of_visits = #visits
  local curpath = Utils.full_path_of_current_buffer()
  local slot = 0
  local ele = vim.tbl_map(function(visit_path) -- slots and corresponding visits
    slot = slot + 1
    local text = vim.fn.fnamemodify(visit_path, ":t") -- visit is full path
    text = text:sub(1, math.min(#text, 2))

    local is_active = curpath == visit_path
    return string.format(is_active and opts.active() or opts.inactive, text)
  end, vim.list_slice(visits, 1, math.min(opts.max_slots, nr_of_visits)))

  if opts.max_slots < nr_of_visits then -- visits without slots
    local active = vim.tbl_filter(
      function(visit_path) return curpath == visit_path end,
      vim.list_slice(visits, opts.max_slots + 1)
    )
    local is_active = #active > 0
    ele[slot + 1] = string.format(is_active and opts.active() or opts.inactive, opts.more_marks)
  end
  local line = table.concat(ele, opts.sep)
  local sep = line == "" and " -" or " "
  cached_line = string.format("%s%s%s", header, sep, line)
  if notify_cb then notify_cb() end
end

local function subscribe()
  local augroup = vim.api.nvim_create_augroup("VisitsLine", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("BufEnter", "*", function() produce() end)
  au("User", "VisitsModified", function() produce() end)
  au("User", "VisitsSwitchedContext", function(event)
    label_name = event.data
    produce()
  end)
end

function M.setup(cb)
  subscribe()
  produce() -- initialize line
  notify_cb = cb
end
function M.has_buffer() return is_current_buffer_labeled end
function M.line() return cached_line end
return M
