--          ╭─────────────────────────────────────────────────────────╮
--          │               Statusline for mini.visits                │
--          ╰─────────────────────────────────────────────────────────╯

-- TODO:
-- Using mini.visits, the order of the list cannot be changed
-- All elements need to be displayed, "more_marks" does not make sense

local M = {}
local MV = require("mini.visits")

local label_name = "core"
local is_current_buffer_labeled = false
local cached_line = nil

local opts = {
  icon = "󰛢", -- nf-md-hook  -- f06e2 -- nerdfont -- area plane a
  label_names = { core = "" },
}

local function produce()
  local name = opts.label_names[label_name]
  name = name and name or label_name
  local header = string.format("%s%s%s", opts.icon, name == "" and "" or " ", name)

  local visits = MV.list_paths(nil, { filter = label_name })
  visits = visits and visits or {}

  is_current_buffer_labeled = false
  local curpath = vim.fn.expand("%:p")
  local status = vim.tbl_map(function(visit) -- slots and corresponding tags
    local is_active = curpath == visit
    if is_active then is_current_buffer_labeled = true end

    local text = vim.fn.fnamemodify(visit, ":t") -- visit is full path
    text = text:sub(1, math.min(#text, 2))
    return is_active and text:upper() or text
  end, visits)

  local sep = "·" -- middledot
  cached_line = header .. " " .. table.concat(status, sep)
end

local function subscribe()
  local augroup = vim.api.nvim_create_augroup("VisitsLine", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("BufEnter", "*", function() produce() end)
  au("User", "VisitsModifiedLabel", function() produce() end)
  au("User", "VisitsSwitchedLabel", function(event)
    label_name = event.data
    produce()
  end)
end

function M.setup(notify_cb)
  subscribe()

  local org_produce = produce
  produce = function()
    org_produce()
    notify_cb()
  end
  org_produce() -- initialize line
end
function M.is_current_buffer_tagged() return is_current_buffer_labeled end
function M.line() return cached_line end
return M
