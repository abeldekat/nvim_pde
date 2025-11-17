-- Extend mini.deps with functions to allow a plugin to be loaded on event or keypress

local M, H = {}, {}

-- Register a plugin to packadd on keymapping or event
M.register = function(spec) table.insert(H.optional_specs, spec) end

-- Add all registered plugins. For example, to update all plugins
M.load_registered = function()
  for _, spec in ipairs(H.optional_specs) do
    MiniDeps.add(spec)
  end
end

M.on_event = function(cb, events, pattern)
  local opts = {
    group = H.augroup_defer,
    desc = "ak_defer",
    once = true,
    callback = function(ev) cb(ev) end,
  }
  if pattern then opts["pattern"] = pattern end
  vim.api.nvim_create_autocmd(events, opts)
end

M.on_keys = function(cb, keys, desc)
  keys = type(keys) == "string" and { keys } or keys
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, function()
      vim.keymap.del("n", key)
      cb() -- key used for lazy loading might be redefined here...
      H.resubmit_key_if_present(key)
    end, { desc = desc, silent = true })
  end
end

H.augroup_defer = vim.api.nvim_create_augroup("ak_defer", {})
H.optional_specs = {}

H.resubmit_key_if_present = function(key_to_resubmit)
  local key_to_use = vim.api.nvim_replace_termcodes(key_to_resubmit, true, true, true)

  local keys = vim.api.nvim_get_keymap("n")
  for _, key in ipairs(keys) do
    ---@diagnostic disable-next-line: undefined-field
    if key.lhs == key_to_use then
      vim.api.nvim_input(key_to_use)
      break
    end
  end
end

return M
