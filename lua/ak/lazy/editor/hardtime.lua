return {
  "takac/vim-hardtime",
  -- lazy = false,
  init = function()
    vim.g.hardtime_default_on = 1
  end,
  keys = {
    { "<leader>mh", "<cmd>HardTimeToggle<cr>", desc = "Toggle HardTime" },
  },
  config = function()
    vim.g.hardtime_ignore_buffer_patterns = { "oil.*", "dbui.*", "dbout.*" }
    vim.g.hardtime_showmsg = 0
    vim.g.hardtime_timeout = 2000
    vim.g.hardtime_ignore_quickfix = 1
    vim.g.hardtime_maxcount = 2
    vim.g.hardtime_allow_different_key = 1
    vim.g.hardtime_motion_with_count_resets = 1
  end,
}
