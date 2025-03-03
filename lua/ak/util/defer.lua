--          ╭─────────────────────────────────────────────────────────╮
--          │  Module containing functions to defer loading a plugin  │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.defer
local M = {}

local defer_group = vim.api.nvim_create_augroup("ak_defer", {})

function M.on_events(cb, events, pattern)
  local opts = {
    group = defer_group,
    desc = "ak_defer",
    once = true,
    callback = function(ev) cb(ev) end,
  }
  if pattern then opts["pattern"] = pattern end
  vim.api.nvim_create_autocmd(events, opts)
end

local function resubmit_key_if_present(key_to_resubmit)
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

function M.on_keys(cb, keys, desc)
  keys = type(keys) == "string" and { keys } or keys
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, function()
      vim.keymap.del("n", key)
      cb() -- key used for lazy loading might be redefined here...
      resubmit_key_if_present(key)
    end, { desc = desc, silent = true })
  end
end

return M
