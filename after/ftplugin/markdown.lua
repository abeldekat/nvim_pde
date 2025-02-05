-- NOTE: Previously used autocommand on filetype,
-- setting vim.opt_local

-- Using `vim.cmd` instead of `vim.wo` because it is yet more reliable
vim.cmd("setlocal spell")
vim.cmd("setlocal wrap")

-- Show line after desired maximum text width
vim.cmd("setlocal colorcolumn=81")
