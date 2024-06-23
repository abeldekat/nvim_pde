--          ╭─────────────────────────────────────────────────────────╮
--          │            Use, when needed, FzfLua builtin             │
--          ╰─────────────────────────────────────────────────────────╯

-- Possibly: image support(LazyVim)
require("fzf-lua").setup()
vim.keymap.set("n", "<leader>fP", "<cmd>FzfLua builtin<cr>", { desc = "Picker builtin", silent = true })
vim.keymap.set(
  "n",
  "ml",
  function() vim.notify("No picker for alternate file") end,
  { desc = "Alternate file", silent = true }
)
