require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip").setup({
  history = true,
  delete_check_events = "TextChanged",
})

vim.keymap.set("i", "<tab>", function()
  return require("luasnip").jumpable(1) and "<plug>luasnip-jump-next" or "<tab>"
end, { expr = true, silent = true })
vim.keymap.set("s", "<tab>", function()
  return require("luasnip").jump(1)
end, {})
vim.keymap.set({ "i", "s" }, "<s-tab>", function()
  return require("luasnip").jump(-1)
end, {})
