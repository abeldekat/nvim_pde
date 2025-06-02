-- A statusline component for a harpoon-like workflow
local HarpoonLine, H = {}, {}

HarpoonLine.setup = function(config, provider)
  _G.HarpoonLine = HarpoonLine
  H.setup_config(config, provider)
  H.create_autocommands()
  H.produce()
end

HarpoonLine.has_buffer = function() return H.is_current_buffer_labeled end

HarpoonLine.line = function() return H.cached_line end

-- Helper ================================================================

H.config = {
  icon = "󰖃", -- visitor: nf-md-walk f0583 -- grapple: "󰛢" nf-md-hook f06e2
  max_slots = 4,
  fmt_inactive = "%s",
  fmt_active = "[%s]",
  text = function(full_path)
    local result = vim.fn.fnamemodify(full_path, ":t") -- visit is full path
    return result:sub(1, math.min(#result, 2)) -- first two letters
  end,
  sep = "·",
  more_marks = "…", -- #slots < #visits, horizontal elipsis
  on_produce = nil, -- function to call when a new line is produced
  highlight_active = nil, -- function, param text, return hl + text
}
H.default_config = vim.deepcopy(H.config)
H.provider = nil -- the plugin providing a harpoon-like workflow...
H.is_current_buffer_labeled = false
H.cached_line = nil

H.setup_config = function(config, provider)
  vim.validate({
    config = { config, "table" },
    provider = { provider, "table" },
  })

  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})

  vim.validate({
    icon = { config.icon, "string" },
    max_slots = { config.max_slots, "number" },
    fmt_inactive = { config.fmt_inactive, "string" },
    fmt_active = { config.fmt_active, "string" },
    text = { config.text, "function" },
    sep = { config.sep, "string" },
    cb = { config.cb, "function", true },
    highlight_active = { config.highlight_active, "function", true },
  })

  H.config = config
  H.provider = provider
end

H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("VisitsHarpoonedLine", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("BufEnter", "*", H.produce_and_cb)
  au("User", H.provider.events.modified, H.produce_and_cb)
end

H.produce_item = function(is_active, text)
  local conf = H.config
  if not is_active then return string.format(conf.fmt_inactive, text) end

  H.is_current_buffer_labeled = true
  return conf.highlight_active and conf.highlight_active(text) or string.format(conf.fmt_active, text)
end

H.produce = function()
  local conf = H.config
  local curpath = H.provider.full_path_of_current_buffer()

  H.is_current_buffer_labeled = false
  local header = string.format("%s %s:", conf.icon, H.provider.get_label())

  local visits = H.provider.list_paths() or {}
  local nr_of_visits = #visits
  local slot = 0
  local ele = vim.tbl_map(function(visit_path) -- slots and corresponding visits
    slot = slot + 1
    return H.produce_item(curpath == visit_path, conf.text(visit_path))
  end, vim.list_slice(visits, 1, math.min(conf.max_slots, nr_of_visits)))

  if conf.max_slots < nr_of_visits then -- visits without slots
    local active = vim.tbl_filter(
      function(visit_path) return curpath == visit_path end,
      vim.list_slice(visits, conf.max_slots + 1)
    )
    ele[slot + 1] = H.produce_item(#active > 0, conf.more_marks)
  end
  local line = table.concat(ele, conf.sep)
  local sep = line == "" and " -" or " "
  H.cached_line = string.format("%s%s%s", header, sep, line)
end

-- Must be wrapped, mini.files might not have a state yet...
H.produce_and_cb = vim.schedule_wrap(function()
  H.produce()
  if H.config.on_produce then H.config.on_produce() end
end)

return HarpoonLine
