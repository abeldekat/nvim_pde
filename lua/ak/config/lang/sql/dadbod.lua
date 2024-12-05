-- This file is intended to be loaded by key. The key is present if the buffer is an sql file.

-- blink.cmp integration from LazyVim:
-- https://github.com/Saghen/blink.cmp/issues/208 Allow providers to disable themselves
-- { -- In lazyvim:
--   "saghen/blink.cmp",
--   optional = true,
--   opts = {
--     sources = {
--       completion = {
--         enabled_providers = { "dadbod" },
--       },
--       providers = {
--         dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
--       },
--     },
--   },
--   dependencies = {
--     "kristijanhusak/vim-dadbod-completion",
--   },
-- },

-- TODO: Blink: Figure out a way to add the provider after blink has been setup
-- NOTE: For now, no completion for blink.cmp, only for nvim-cmp
--
-- dadbod-ui and mysql: ft hardcoded to "mysql", breaking treesitter and comment
-- 1. use dadbod for autocompletion, combine with vim-slime and mysql cli
-- 2. in .envrc construct $DATABASE_URL
local function apply()
  local has_nvim_cmp, cmp = pcall(require, "cmp")
  if has_nvim_cmp then cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } }) end

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

vim.cmd("DBCompletionClearCache") -- current buffer completion
apply()

-- dadbod is loaded, change the key to no-op
vim.keymap.set("n", "md", function() vim.print("Loaded dadbod") end, { desc = "Load dadbod", silent = true })
