vim.g.slime_target = "neovim"

-- Find neovim terminal job id: echo &channel
-- After repl starts: use <c-c><c-c>
vim.keymap.set("n", "<leader>mr", "<cmd>echom &channel<cr>", { desc = "Repl", silent = true })
