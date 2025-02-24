--[[

Use a notification window like fidget.nvim for messages from the lsp,
and a regular window otherwise.

Do note that when the lsp emits messages, any regular message
from vim.notify will be displayed in the same lsp window.
This is acceptable.

--]]

local H = {}
local function setup()
  H.map("<leader>un", function() MiniNotify.clear() end, "Notify clear")
  H.map("<leader>on", function() MiniNotify.show_history() end, "Notify history")
  H.create_autocommmands()

  require("mini.notify").setup({}) -- just the defaults...
  vim.notify = MiniNotify.make_notify()

  -- The idea: Based on context, use two separate configs:
  H.config_default = MiniNotify.config -- the config constructed by mini
  H.config_on_lsp_progress = vim.tbl_deep_extend("force", {}, H.config_default, {
    lsp_progress = { duration_last = 500 }, -- default 1000
    content = { format = H.format_on_lsp_progress }, -- sort = H.filterout_lua_diagnosing
    window = { config = H.win_config_on_lsp_progress(), winblend = 95 }, -- default blend 25
  })
end

H.create_autocommmands = function()
  local gr = vim.api.nvim_create_augroup("ak_mini_notify", {})
  local au = function(event, pattern, callback)
    vim.api.nvim_create_autocmd(event, { group = gr, pattern = pattern, callback = callback })
  end
  local au_local = function(event, callback)
    vim.api.nvim_create_autocmd(event, { group = gr, buffer = 0, callback = callback })
  end

  -- MiniNotify created a new buffer:
  au("FileType", "mininotify", function()
    --  When the notify buffer is no longer displayed, use the default config
    au_local("BufHidden", function() MiniNotify.config = H.config_default end)
  end)
  -- On LspProgress, use the lsp progress config
  au("LspProgress", "begin", function() MiniNotify.config = H.config_on_lsp_progress end)
end

-- H.not_lua_diagnosing = function(notif) return not vim.startswith(notif.msg, "lua_ls: Diagnosing") end
-- H.filterout_lua_diagnosing = function(notif_arr)
--   return MiniNotify.default_sort(vim.tbl_filter(H.not_lua_diagnosing, notif_arr))
-- end

--- Skip the time and the bar (|)
H.format_on_lsp_progress = function(notif)
  notif.hl_group = "Comment"
  return notif.msg
end

--- Customize window to be more "fidget" like
H.win_config_on_lsp_progress = function()
  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 2 or 0) -- 2 looks better than 1
  return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad, border = "none" }
end

H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

H.config_default = {}
H.config_on_lsp_progress = {}

setup()
