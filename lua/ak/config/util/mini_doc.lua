require("mini.doc").setup()

vim.keymap.set("n", "<leader>md", "<Cmd>lua MiniDoc.generate()<CR>", { desc = "Generate plugin doc", silent = true })
