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

-- Lessons learned from hardtime:
-- 1. Use a instead of li
-- 3. Use dj instead of 2dd
-- 8. Use yj instead of 2yy
-- 11. Use Y instead of y$
-- 16. Use D instead of d$

-- notify_many_keys("h")
notify_many_keys("j")
notify_many_keys("k")
-- notify_many_keys("l")

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Hardtime                        │
--          ╰─────────────────────────────────────────────────────────╯
-- local spec_hardtime = "m4xshen/hardtime.nvim"
-- local function hardtime()
--   add(spec_hardtime)
--   require("ak.config.editor.hardtime")
-- end
-- if use_hardtime then
--   hardtime()
-- else
--   register(spec_hardtime)
--   Util.defer.on_keys(hardtime, "<leader>oh", "Hardtime start/report")
-- end

-- :Hardtime report -> has nui plugin dependency.
-- Copy the code(hardtime.report.lua) and use vim.notify instead:

-- local report = function()
-- local file_path = vim.api.nvim_call_function("stdpath", { "log" }) .. "/hardtime.nvim.log"
-- local file = io.open(file_path, "r") -- in .local/state/nvim
-- if file == nil then
--   vim.notify("No hardtime messages.", vim.log.levels.INFO) -- Not an error...
--   return
-- end
--
-- local hints = {}
-- for line in file:lines() do
--   local hint = string.gsub(line, "%[.-%] ", "")
--   hints[hint] = hints[hint] and hints[hint] + 1 or 1
-- end
-- file:close()
--
-- local sorted_hints = {}
-- for hint, count in pairs(hints) do
--   table.insert(sorted_hints, { hint, count })
-- end
-- if vim.tbl_isempty(sorted_hints) then
--   vim.notify("No hardtime messages", vim.log.levels.INFO)
--   return
-- end
--
-- -- There are messages:
-- table.sort(sorted_hints, function(a, b) return a[2] > b[2] end)
-- local hints_iter = vim
--   .iter(ipairs(sorted_hints))
--   :map(function(i, v) return string.format("%d. %s (%d times)", i, v[1], v[2]) end)
-- vim.notify("\n" .. table.concat(hints_iter:totable(), "\n"), vim.log.levels.INFO)
-- end

-- require("hardtime").setup({
--   -- restriction_mode = "block" -- hint
--   -- max_count = 3,
--   restricted_keys = {
--     ["<C-N>"] = { "x" }, -- using c-n for ctrl-d in normal mode
--   },
-- })
-- vim.keymap.set("n", "<leader>uh", "<cmd>Hardtime toggle<cr>", { desc = "Toggle hardime", silent = true })
-- vim.keymap.set("n", "<leader>oh", report, { desc = "Report hardime", silent = true })
