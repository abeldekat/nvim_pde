require("mini.keymap").setup()
-- Navigate 'mini.completion' menu with `<Tab>` /  `<S-Tab>`
-- MiniKeymap.map_multistep("i", "<Tab>", { "pmenu_next" })
-- MiniKeymap.map_multistep("i", "<S-Tab>", { "pmenu_prev" })

-- On `<CR>` try to accept current completion item, fall back to accounting
-- for pairs from 'mini.pairs'
MiniKeymap.map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
-- On `<BS>` just try to account for pairs from 'mini.pairs'
MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })

local steps_ctrl_l = { "minisnippets_next", "jump_after_tsnode", "jump_after_close" }
MiniKeymap.map_multistep("i", "<C-l>", steps_ctrl_l)
local steps_ctrl_h = { "minisnippets_prev", "jump_before_tsnode", "jump_before_open" }
MiniKeymap.map_multistep("i", "<C-h>", steps_ctrl_h)

-- Lessons learned from m4xshen/hardtime.nvim:
-- 1. Use a instead of li
-- 3. Use dj instead of 2dd
-- 8. Use yj instead of 2yy
-- 11. Use Y instead of y$
-- 16. Use D instead of d$

-- local do_action = false
-- local action_delay = 5
-- local action_timer = vim.loop.new_timer() or {}
--
-- local notify_many_keys = function(key)
--   local lhs = string.rep(key, 4)
--   local action = function()
--     if do_action then return end
--
--     do_action = true
--     vim.notify(string.format("Too many %s. \n **Shutdown** in %ds!", key, action_delay))
--
--     local shutdown = vim.schedule_wrap(function()
--       vim.cmd("qa!")
--       -- Consider:
--       -- vim.system({ "sudo", "reboot", "now" })
--     end)
--     action_timer:start(action_delay * 1000, 0, shutdown)
--   end
--   MiniKeymap.map_combo({ "n", "x" }, lhs, action)
-- end
--
-- notify_many_keys("j")
-- notify_many_keys("k")
