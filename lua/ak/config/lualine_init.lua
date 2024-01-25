--          ╭─────────────────────────────────────────────────────────╮
--          │   no statusline on dashboard, empty statusline until    │
--          │                    lualine is loaded                    │
--          ╰─────────────────────────────────────────────────────────╯

vim.g.lualine_laststatus = vim.o.laststatus
if vim.fn.argc(-1) > 0 then
  vim.o.statusline = " "
else
  vim.o.laststatus = 0
end
