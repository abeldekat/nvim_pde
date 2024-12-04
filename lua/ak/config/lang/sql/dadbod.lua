-- dadbod-ui and mysql: ft hardcoded to "mysql", breaking treesitter and comment
-- use dadbod for autocompletion, combine with vim-slime and mysql cli
-- in .envrc construct $DATABASE_URL
-- or in .lazy.lua: w:db b:db g:db

-- TODO: blink.cmp integration in LazyVim
-- {
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

local function add_completion()
  local ok, cmp = pcall(require, "cmp")
  if ok then cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } }) end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "sql" },
  callback = add_completion,
})

vim.cmd("DBCompletionClearCache") -- current buffer completion
add_completion()

-- dadbod can be lazy loaded:
vim.keymap.set("n", "md", function() vim.print("Loaded dadbod") end, { desc = "Load dadbod", silent = true })

-- execute a query without vim-slime and the mysql cli:
vim.keymap.set("n", "mq", function()
  vim.cmd('norm! "xyip') -- send the paragraph to reg x
  vim.cmd("silent! db " .. vim.fn.getreg("x")) -- <cmd>silent! %db<cr>
end, { desc = "Run sql in paragraph", silent = true })
