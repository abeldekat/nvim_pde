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

function M.on_keys(cb, keys, desc)
  keys = type(keys) == "string" and { keys } or keys
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, function()
      vim.keymap.del("n", key)
      cb()
      vim.api.nvim_input(vim.api.nvim_replace_termcodes(key, true, true, true))
    end, { desc = desc, silent = true })
  end
end

return M
