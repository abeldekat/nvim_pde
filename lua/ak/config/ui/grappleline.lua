-- Replaced by visitsline...

local M = {}
local Util = require("ak.util")
local Grapple = require("grapple")

local scopes = Util.labels.grapple
local scope_name = scopes[1]
local is_current_buffer_tagged = false
local cached_line
local notify_cb

local opts = {
  -- Supplementary private use Area Plane-A
  -- https://www.nerdfonts.com/cheat-sheet?q=nf-md-
  icon = "󰛢", -- nf-md-hook  -- f06e2
  scope_names = { [scopes[1]] = "", [scopes[2]] = "dev" },
  max_slots = 4,
  inactive = "%s",
  active = function()
    is_current_buffer_tagged = true
    return "[%s]"
  end,
  more_marks = "…", -- #slots < #tags, horizontal elipsis
}

local function produce() -- "󰛢 12" "󰛢 1[2]34…" "󰛢 1234[…]"
  local current = Grapple.find({ buffer = 0 })
  local tags, _ = Grapple.tags() -- using the current scope
  tags = tags and tags or {}
  is_current_buffer_tagged = false

  local scope = opts.scope_names[scope_name] or scope_name
  local header = string.format("%s%s%s", opts.icon, scope == "" and "" or " ", scope)

  local nr_of_tags = #tags
  local curpath = current and current.path
  local slot = 0
  ---@type string[]
  local ele = vim.tbl_map(function(tag) -- slots and corresponding tags
    slot = slot + 1
    return string.format(curpath == tag.path and opts.active() or opts.inactive, "" .. slot)
  end, vim.list_slice(tags, 1, math.min(opts.max_slots, nr_of_tags)))

  if opts.max_slots < nr_of_tags then -- tags without slots
    local active = vim.tbl_filter(
      function(tag) return curpath == tag.path end,
      vim.list_slice(tags, opts.max_slots + 1)
    )
    ele[slot + 1] = string.format(#active > 0 and opts.active() or opts.inactive, opts.more_marks)
  end
  local line = table.concat(ele)
  local sep = line == "" and " -" or " "
  cached_line = string.format("%s%s%s", header, sep, line)
  if notify_cb then notify_cb() end
end

local function subscribe()
  local augroup = vim.api.nvim_create_augroup("Grappleline", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end
  au("BufEnter", "*", function() produce() end)
  au("User", "GrappleModified", function() produce() end)
  au("User", "GrappleSwitchedContext", function(event)
    scope_name = event.data
    produce()
  end)
end

function M.setup(cb)
  subscribe()
  produce() -- initialize line
  notify_cb = cb
end
function M.has_buffer() return is_current_buffer_tagged end
function M.line() return cached_line end
return M
