local Visitsline = {}
local Utils = require("ak.util")
local CustomVisits = Utils.visits
local H = {}

Visitsline.setup = function(config)
  _G.Visitsline = Visitsline

  config = H.setup_config(config)
  H.apply_config(config)
  H.produce() -- initialize line
  H.create_autocommands()
end
Visitsline.has_buffer = function() return H.is_current_buffer_labeled end
Visitsline.line = function() return H.cached_line end

Visitsline.config = {
  -- icon = "󰛢", -- nf-md-hook  -- f06e2 -- nerdfont -- area plane a
  icon = "󰖃", -- a visitor -- nf-md-walk  -- f0583
  label_names = {}, -- label_name - label_name_override to display
  max_slots = 4,
  fmt_inactive = "%s",
  fmt_active = "[%s]",
  text = function(full_path)
    local result = vim.fn.fnamemodify(full_path, ":t") -- visit is full path
    return result:sub(1, math.min(#result, 2))
  end,
  highlight_active = nil, -- function, param text, returns text + hl
  sep = "·",
  more_marks = "…", -- #slots < #visits, horizontal elipsis
}

H.default_config = vim.deepcopy(Visitsline.config)
H.label_name = CustomVisits.start_label
H.is_current_buffer_labeled = false
H.cached_line = nil

H.produce_item = function(is_active, text, conf)
  if not is_active then return string.format(conf.fmt_inactive, text) end

  H.is_current_buffer_labeled = true
  return conf.highlight_active and conf.highlight_active(text) or string.format(conf.fmt_active, text)
end

H.produce = function()
  local visits = CustomVisits.list_paths(H.label_name) or {}
  H.is_current_buffer_labeled = false
  local conf = H.get_config()

  local label = conf.label_names[H.label_name] or string.format("%s:", H.label_name)
  local header = string.format("%s%s%s", conf.icon, label == "" and "" or " ", label)

  local nr_of_visits = #visits
  local curpath = Utils.full_path_of_current_buffer()
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

H.produce_and_cb = function()
  local conf = H.get_config()
  H.produce()
  if conf.cb then conf.cb() end
end

H.setup_config = function(config)
  config = vim.tbl_deep_extend("force", vim.deepcopy(H.default_config), config or {})
  return config
end

H.apply_config = function(config) Visitsline.config = config end

H.get_config = function(_) -- config
  -- return vim.tbl_deep_extend("force", Visitsline.config, vim.b.visitsline_config or {}, config or {})
  return Visitsline.config
end

H.create_autocommands = function()
  local augroup = vim.api.nvim_create_augroup("VisitsLine", { clear = true })
  local au = function(event, pattern, callback, desc)
    vim.api.nvim_create_autocmd(event, { group = augroup, pattern = pattern, callback = callback, desc = desc })
  end

  au("BufEnter", "*", H.produce_and_cb)
  au("User", "VisitsModified", H.produce_and_cb)
  au("User", "VisitsSwitchedContext", function(event)
    H.label_name = event.data
    H.produce_and_cb()
  end)
end

return Visitsline
