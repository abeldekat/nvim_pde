--          ╭─────────────────────────────────────────────────────────╮
--          │             Module containing paq utilities             │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.paq
local M = {}

local lazy_paq = vim.api.nvim_create_augroup("ak_lazy_pac", { clear = true })

function M.setup() end

function M.on_events(cb, events, pattern)
  vim.api.nvim_create_autocmd(events, {
    group = lazy_paq,
    pattern = pattern,
    desc = "ak_lazy_pac",
    once = true,
    callback = function(ev)
      cb(ev)
    end,
  })
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
