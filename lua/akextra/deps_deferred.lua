-- Extend mini.deps with utility functions

local M, H = {}, {}

-- Register a plugin to packadd on demand
M.register = function(spec) table.insert(H.optional_specs, spec) end

-- Add all registered plugins. For example, to update all plugins
M.load_registered = function()
  for _, spec in ipairs(H.optional_specs) do
    MiniDeps.add(spec)
  end
end

M.on_keys = function(keys, cb, desc) -- not in use at the moment...
  keys = type(keys) == 'string' and { keys } or keys
  for _, key in ipairs(keys) do
    vim.keymap.set('n', key, function()
      vim.keymap.del('n', key)
      cb()
      -- Resubmit key if defined in cb
      H.resubmit_key_if_present(key)
    end, { desc = desc, silent = true })
  end
end

H.optional_specs = {}

H.resubmit_key_if_present = function(key_to_resubmit)
  local key_to_use = vim.api.nvim_replace_termcodes(key_to_resubmit, true, true, true)

  local keys = vim.api.nvim_get_keymap('n')
  for _, key in ipairs(keys) do
    ---@diagnostic disable-next-line: undefined-field
    if key.lhs == key_to_use then
      vim.api.nvim_input(key_to_use)
      break
    end
  end
end

return M
