--          ╭─────────────────────────────────────────────────────────╮
--          │            Use, when needed, FzfLua builtin             │
--          ╰─────────────────────────────────────────────────────────╯

-- F1: help
-- F4: toggle preview
-- tab select multiple
-- alt-q to quickfix list

-- Possibly: image support(LazyVim)
require("fzf-lua").setup()
vim.keymap.set("n", "<leader>fi", "<cmd>FzfLua builtin<cr>", { desc = "Picker builtin", silent = true })
vim.keymap.set(
  "n",
  "ml",
  function() vim.notify("No picker for alternate file") end,
  { desc = "Alternate file", silent = true }
)
