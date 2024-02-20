local MiniNotify = require("mini.notify")
MiniNotify.setup()

-- Change duration for errors to show them longer
-- local opts = { ERROR = { duration = 10000 } }
vim.notify = MiniNotify.make_notify() -- opts

vim.keymap.set("n", "<leader>sna", function()
  local result = vim.tbl_filter(function(notif) return notif.ts_remove == nil end, MiniNotify.get_all())
  vim.print(vim.inspect(result))
end, {
  desc = "MiniNotify print active",
  silent = true,
})

vim.keymap.set("n", "<leader>snc", function() MiniNotify.clear() end, {
  desc = "MiniNotify clear",
  silent = true,
})

vim.keymap.set("n", "<leader>snh", function() MiniNotify.show_history() end, {
  desc = "MiniNotify history",
  silent = true,
})

vim.keymap.set("n", "<leader>snr", function() MiniNotify.refresh() end, {
  desc = "MiniNotify refresh",
  silent = true,
})
