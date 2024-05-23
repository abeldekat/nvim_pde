--          ╭─────────────────────────────────────────────────────────╮
--          │                   Grapple statusline                    │
--          ╰─────────────────────────────────────────────────────────╯
local M = {}
local Grapple = require("grapple")
local scope_name = ""
local is_current_buffer_tagged = false
local cached_line = nil

local opts = {
  -- Supplementary private use Area Plane-A
  -- https://www.nerdfonts.com/cheat-sheet?q=nf-md-
  icon = "󰛢", -- nf-md-hook  -- f06e2
  scope_names = { git = "", git_branch = "dev" },
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

  local header = string.format("%s%s%s", opts.icon, scope_name == "" and "" or " ", scope_name)

  local nr_of_tags = #tags
  local curpath = current and current.path or nil
  local slot = 0
  ---@type string[]
  local status = vim.tbl_map(function(tag) -- slots and corresponding tags
    slot = slot + 1
    return string.format(curpath == tag.path and opts.active() or opts.inactive, "" .. slot)
  end, vim.list_slice(tags, 1, math.min(opts.max_slots, nr_of_tags)))

  if opts.max_slots < nr_of_tags then -- tags without slots
    local active = vim.tbl_filter(
      function(tag) return curpath == tag.path and true or false end,
      vim.list_slice(tags, opts.max_slots + 1)
    )
    status[slot + 1] = string.format(#active > 0 and opts.active() or opts.inactive, opts.more_marks)
  end

  local tagline = table.concat(status)
  tagline = tagline == "" and "-" or (" " .. tagline)
  cached_line = header .. tagline
end

local function set_scope_name(name)
  local scope_name_override = opts.scope_names[name]
  scope_name = scope_name_override and scope_name_override or name
end

local function subscribe()
  local function decorate(org_cmd)
    return function(...)
      org_cmd(...)
      produce()
    end
  end
  for _, name in ipairs({ "toggle", "tag", "untag", "reset" }) do
    Grapple[name] = decorate(Grapple[name])
  end

  local use_scope = Grapple.use_scope
  ---@diagnostic disable-next-line: duplicate-set-field
  Grapple.use_scope = function(name)
    use_scope(name)
    set_scope_name(name)
    produce()
  end

  local group = vim.api.nvim_create_augroup("Grappleline", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    group = group,
    pattern = "*",
    callback = function() produce() end,
  })
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
function M.is_current_buffer_tagged() return is_current_buffer_tagged end
function M.line() return cached_line end
return M
