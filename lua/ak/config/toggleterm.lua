require("toggleterm").setup({
  size = 15,
  open_mapping = [[<c-_>]],
  insert_mappings = false,
  terminal_mappings = false,
  shading_factor = 2,
  direction = "horizontal",
})

--To map /: use <C-_> instead of <C-/>.
vim.keymap.set("n", [[<c-_>]], "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal", silent = true })
