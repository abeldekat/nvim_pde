require("neogen").setup({
  snippet_engine = "luasnip",
  languages = {
    lua = { template = { annotation_convention = "emmylua" } },
  },
})

-- will generate annotation for the function, class or other relevant type you're currently in
vim.keymap.set("n", "<leader>mn", "<cmd>Neogen<cr>", { desc = "Document", silent = true })
