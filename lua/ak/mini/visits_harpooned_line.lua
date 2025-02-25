-- A statusline component for VisitsHarpooned
-- Requirements:
-- 1. VisitsHarpooned active

local VisitsHarpoonedLine = {}
local H = {}

VisitsHarpoonedLine.setup = function(config)
  _G.VisitsHarpoonedLine = VisitsHarpoonedLine
  config = H.setup_config(config)
  H.apply_config(config)
  H.create_autocommands()

  H.current_label = VisitsHarpooned.get_start_label()
  H.produce()
end

VisitsHarpoonedLine.config = {
  icon = "󰖃", -- visitor: nf-md-walk f0583 -- grapple: "󰛢" nf-md-hook f06e2
  max_slots = 4,
  fmt_inactive = "%s",
  fmt_active = "[%s]",
  text = function(full_path)
    local result = vim.fn.fnamemodify(full_path, ":t") -- visit is full path
    return result:sub(1, math.min(#result, 2))
  end,
  sep = "·",
  more_marks = "…", -- #slots < #visits, horizontal elipsis
  cb = nil, -- function updating the statusline
  highlight_active = nil, -- function, param text, return hl + text
}

VisitsHarpoonedLine.has_buffer = function() return H.is_current_buffer_labeled end

VisitsHarpoonedLine.line = function() return H.cached_line end

-- Helper ================================================================

H.default_config = vim.deepcopy(VisitsHarpoonedLine.config)
H.current_label = nil
H.is_current_buffer_labeled = false
H.cached_line = nil

H.setup_config = function(config)
  vim.validate({
    VisitsHarpooned = { VisitsHarpooned, "table" },
    config = { config, "table" },
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
  return config
end

H.apply_config = function(config) VisitsHarpoonedLine.config = config end

H.get_config = function()
  -- No buffer override: vim.b.akminivisitsharpoonedline or {}
  -- No config arg to merge
  -- return vim.tbl_deep_extend("force", VisitsHarpoonedLine.config or {}, config or {})
  return VisitsHarpoonedLine.config
end

H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("VisitsHarpoonedLine", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("BufEnter", "*", function(ev) H.produce_and_cb() end)
  au("User", "VisitsHarpoonedModified", function(ev) H.produce_and_cb() end)
  au("User", "VisitsHarpoonedChangedActiveLabel", function(ev)
    H.current_label = ev.data
    H.produce_and_cb()
  end)
end

H.produce_item = function(is_active, text, conf)
  if not is_active then return string.format(conf.fmt_inactive, text) end

  H.is_current_buffer_labeled = true
  return conf.highlight_active and conf.highlight_active(text) or string.format(conf.fmt_active, text)
end

H.produce = function()
  local curpath = VisitsHarpooned.full_path_of_current_buffer()

  local conf = H.get_config()
  H.is_current_buffer_labeled = false
  local header = string.format("%s %s:", conf.icon, H.current_label)

  local visits = VisitsHarpooned.list_paths(H.current_label) or {}
  local nr_of_visits = #visits
  local slot = 0
  local ele = vim.tbl_map(function(visit_path) -- slots and corresponding visits
    slot = slot + 1
    return H.produce_item(curpath == visit_path, conf.text(visit_path), conf)
  end, vim.list_slice(visits, 1, math.min(conf.max_slots, nr_of_visits)))

  if conf.max_slots < nr_of_visits then -- visits without slots
    local active = vim.tbl_filter(
      function(visit_path) return curpath == visit_path end,
      vim.list_slice(visits, conf.max_slots + 1)
    )
    ele[slot + 1] = H.produce_item(#active > 0, conf.more_marks, conf)
  end
  local line = table.concat(ele, conf.sep)
  local sep = line == "" and " -" or " "
  H.cached_line = string.format("%s%s%s", header, sep, line)
end

-- Must be wrapped, mini.files might not have a state yet...
H.produce_and_cb = vim.schedule_wrap(function()
  H.produce()
  local conf = H.get_config()
  if conf.cb then conf.cb() end
end)

return VisitsHarpoonedLine
