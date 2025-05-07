-- This file is intended to be loaded by key. The key is present if the buffer is an sql file.

-- dadbod-ui and mysql: ft hardcoded to "mysql", breaking treesitter and comment
-- 1. combine vim-slime and mysql cli
-- 2. in .envrc construct $DATABASE_URL
local function apply()
  -- execute a query without vim-slime and the mysql cli:
  vim.keymap.set("n", "mq", function()
    vim.cmd('norm! "xyip') -- send the paragraph to reg x
    vim.cmd("silent! db " .. vim.fn.getreg("x")) -- <cmd>silent! %db<cr>
  end, { desc = "Run sql in paragraph", silent = true, buffer = true })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  callback = apply,
})
apply()
