-- Lessons learned from m4xshen/hardtime.nvim:
-- 1. Use a instead of li
-- 3. Use dj instead of 2dd
-- 8. Use yj instead of 2yy
-- 11. Use Y instead of y$
-- 16. Use D instead of d$

if not MiniKeymap then return end

local do_action = false
local action_delay = 5
local action_timer = vim.loop.new_timer() or {}

local notify_many_keys = function(key)
  local lhs = string.rep(key, 4)
  local action = function()
    if do_action then return end

    do_action = true
    vim.notify(string.format("After all these years, still too many %s. \n Shutdown in %ds!", key, action_delay))

    local shutdown = vim.schedule_wrap(function()
      vim.cmd("qa!")
      -- Consider:
      -- vim.system({ "sudo", "reboot", "now" })
    end)
    action_timer:start(action_delay * 1000, 0, shutdown)
  end
  MiniKeymap.map_combo({ "n", "x" }, lhs, action)
end

notify_many_keys("j")
notify_many_keys("k")
