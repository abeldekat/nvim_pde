local Util = require("ak.util")
local use_lsp_progress = true

local not_lua_diagnosing = function(notif) return not vim.startswith(notif.msg, "lua_ls: Diagnosing") end
local filterout_lua_diagnosing = function(notif_arr)
  return MiniNotify.default_sort(vim.tbl_filter(not_lua_diagnosing, notif_arr))
end
local format = function(notif) return notif.msg end -- skip the time
local win_config = function()
  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 2 or 0)
  return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad, border = "none" }
end

local content = {}
if use_lsp_progress then
  content.sort = filterout_lua_diagnosing
  content.format = format
end

local lsp_progress = { enable = false }
if use_lsp_progress then
  lsp_progress.enable = true
  lsp_progress.duration_last = 500 -- default 1000
end

local window = {}
if use_lsp_progress then
  window.config = win_config()
  window.winblend = 95 -- like fidget, blend in -- 25
  -- window.max_width_share = 0.300 -- 0.382,
end

local config = {
  content = content,
  lsp_progress = lsp_progress,
  window = window,
}
require("mini.notify").setup(config)
local notify_opts = {
  INFO = { duration = 1000 }, -- 5000
}
vim.notify = MiniNotify.make_notify(notify_opts)

vim.keymap.set("n", "<leader>un", function() MiniNotify.clear() end, {
  desc = "Notify clear",
  silent = true,
})

vim.keymap.set("n", "<leader>on", function() MiniNotify.show_history() end, {
  desc = "Notify history",
  silent = true,
})
