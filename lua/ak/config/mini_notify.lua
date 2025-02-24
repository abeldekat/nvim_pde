--[[
Use a notification window like fidget.nvim for messages from the lsp,
and a regular window otherwise.

Do note that when the lsp emits messages, any regular message
from vim.notify will be displayed in the same lsp window.
This is acceptable.
--]]

--- LSP
local n_progress = 0
local in_lsp_progress = function() return n_progress > 0 end

local lsp_progress_plus = function() n_progress = n_progress + 1 end
vim.api.nvim_create_autocmd("LspProgress", { pattern = "begin", callback = lsp_progress_plus })
local lsp_progress_minus = function()
  vim.defer_fn(function() n_progress = n_progress - 1 end, MiniNotify.config.lsp_progress.duration_last + 1)
end
vim.api.nvim_create_autocmd("LspProgress", { pattern = "end", callback = lsp_progress_minus })

--- Helpers for custom setup
local format = function(notif)
  if not in_lsp_progress() then return MiniNotify.default_format(notif) end
  -- Weird that this works, as this is not the right place to do it (not sure
  -- if there is the one better, though)
  notif.hl_group = "Comment"
  return notif.msg
end

--- The window config differs between "vim.notify"  and "in lsp progress"
local window_config = function()
  if not in_lsp_progress() then return {} end -- by default no override

  -- Customize window to be more "fidget" like
  local pad = vim.o.cmdheight + (vim.o.laststatus > 0 and 2 or 0) -- 2 looks better than 1
  return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad, border = "none" }
end

-- Setup 'mini.notify'
require("mini.notify").setup({
  lsp_progress = { duration_last = 500 }, -- default duration: 1000
  content = { format = format }, -- sort = H.filterout_lua_diagnosing
  window = { winblend = 95, config = window_config },
})
vim.notify = MiniNotify.make_notify()

-- Make mappings
local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end
map("<leader>un", function() MiniNotify.clear() end, "Notify clear")
map("<leader>on", function() MiniNotify.show_history() end, "Notify history")
