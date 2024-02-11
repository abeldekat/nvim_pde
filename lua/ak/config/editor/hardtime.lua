vim.g.hardtime_default_on = 0

vim.g.hardtime_ignore_buffer_patterns = { "oil.*", "dbui.*", "dbout.*" }
vim.g.hardtime_showmsg = 0
vim.g.hardtime_timeout = 2000
vim.g.hardtime_ignore_quickfix = 1
vim.g.hardtime_maxcount = 2
vim.g.hardtime_allow_different_key = 1
vim.g.hardtime_motion_with_count_resets = 1

vim.keymap.set("n", "<leader>uh", "<cmd>HardTimeToggle<cr>", { desc = "Toggle hardime", silent = true })
