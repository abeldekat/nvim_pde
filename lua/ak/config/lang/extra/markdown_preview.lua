vim.cmd([[do FileType]])

vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview", silent = true })
