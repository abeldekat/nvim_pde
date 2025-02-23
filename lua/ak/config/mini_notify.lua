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

  require("mini.notify").setup(H.config_default)
  vim.notify = MiniNotify.make_notify()
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
    --  When the notify buffer is no longer displayed, make sure the buffer config falls back to default:
    au_local("BufHidden", function() vim.b.mininotify_config = nil end)
  end)

  -- Make sure that correct buffer config is set when lsp emits messages:
  au("LspProgress", "begin", function() vim.b.mininotify_config = H.config_on_lsp_progress end)
end

H.not_lua_diagnosing = function(notif) return not vim.startswith(notif.msg, "lua_ls: Diagnosing") end

H.filterout_lua_diagnosing = function(notif_arr)
  return MiniNotify.default_sort(vim.tbl_filter(H.not_lua_diagnosing, notif_arr))
end

H.format = function(notif) return notif.msg end -- skip the time and |

H.win_config = function()
  local has_statusline = vim.o.laststatus > 0
  local pad = vim.o.cmdheight + (has_statusline and 2 or 0) -- 2 instead of 1
  return { anchor = "SE", col = vim.o.columns, row = vim.o.lines - pad, border = "none" }
end

H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

H.config_default = { -- lsp_progress is enabled by default
  lsp_progress = { duration_last = 500 }, -- default 1000
  content = { sort = H.filterout_lua_diagnosing },
}

H.config_on_lsp_progress = {
  -- Add format, removes timestamp and bar(|):
  content = { format = H.format },
  -- Default blend is 25. Add window like fidget.nvim:
  window = { config = H.win_config(), winblend = 95 },
}

setup()
