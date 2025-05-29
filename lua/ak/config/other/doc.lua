require("mini.doc").setup()

vim.keymap.set("n", "<leader>oD", "<Cmd>lua MiniDoc.generate()<CR>", { desc = "Generate plugin doc", silent = true })
