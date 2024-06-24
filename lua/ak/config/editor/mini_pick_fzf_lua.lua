--          ╭─────────────────────────────────────────────────────────╮
--          │            Use, when needed, FzfLua builtin             │
--          ╰─────────────────────────────────────────────────────────╯

-- F1: help
-- F4: toggle preview
-- tab select multiple
-- alt-q to quickfix list

require("fzf-lua").setup({
  winopts = {
    split = "belowright new", -- mini.pick is also below...
  },
})
vim.keymap.set("n", "<leader>fi", "<cmd>FzfLua builtin<cr>", { desc = "Fzf-lua builtin", silent = true })
