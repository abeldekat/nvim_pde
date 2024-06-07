local has_luasnip, _ = pcall(require, "luasnip")
require("neogen").setup({
  snippet_engine = has_luasnip and "luasnip" or "nvim",
  -- languages = {
  --   lua = { template = { annotation_convention = "emmylua" } },
  -- },
})

-- will generate annotation for the function, class or other relevant type you're currently in
vim.keymap.set("n", "<leader>mn", "<cmd>Neogen<cr>", { desc = "Document", silent = true })
