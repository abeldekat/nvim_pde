local M = {}

function M.init()
  vim.g.hardtime_default_on = 1 -- when hardtime is not lazy this is needed
end

function M.setup()
  vim.g.hardtime_ignore_buffer_patterns = { "oil.*", "dbui.*", "dbout.*" }
  vim.g.hardtime_showmsg = 0
  vim.g.hardtime_timeout = 2000
  vim.g.hardtime_ignore_quickfix = 1
  vim.g.hardtime_maxcount = 2
  vim.g.hardtime_allow_different_key = 1
  vim.g.hardtime_motion_with_count_resets = 1

  vim.keymap.set("n", "<leader>mh", "<cmd>HardTimeToggle<cr>", { desc = "Toggle hardime", silent = true })
end

return M
