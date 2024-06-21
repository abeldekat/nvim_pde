local MiniNotify = require("mini.notify")
MiniNotify.setup({ lsp_progress = { enable = false } })

-- Change duration for errors to show them longer
-- local opts = { ERROR = { duration = 10000 } }
local mini_notify = MiniNotify.make_notify() -- opts

-- local org_notify = vim.notify
---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, _) -- opts
  -- if type(level) == "string" then -- python semshi error, don't crash
  --   org_notify(msg, level, opts)
  -- else
  mini_notify(msg, level)
  -- end
end

-- vim.keymap.set("n", "<leader>sna", function()
--   local result = vim.tbl_filter(function(notif) return notif.ts_remove == nil end, MiniNotify.get_all())
--   vim.print(vim.inspect(result))
-- end, {
--   desc = "MiniNotify print active",
--   silent = true,
-- })

vim.keymap.set("n", "<leader>un", function() MiniNotify.clear() end, {
  desc = "Notify clear",
  silent = true,
})

vim.keymap.set("n", "<leader>mn", function() MiniNotify.show_history() end, {
  desc = "Notify history",
  silent = true,
})

-- vim.keymap.set("n", "<leader>snr", function() MiniNotify.refresh() end, {
--   desc = "MiniNotify refresh",
--   silent = true,
-- })
