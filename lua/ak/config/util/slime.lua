vim.g.slime_target = "neovim"

-- Find neovim terminal job id: echo &channel
-- Use this keymap in the terminal in normal mode
-- The repl starts when typing <c-c><c-c>
vim.keymap.set("n", "<leader>or", "<cmd>echom &channel<cr>", { desc = "Repl", silent = true })
