vim.cmd([[do FileType]])

-- ft = "markdown",
vim.keymap.set("n", "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview", silent = true })
