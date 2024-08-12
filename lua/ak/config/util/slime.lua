-- Find neovim terminal job id: echo &channel:
-- vim.keymap.set("n", "<leader>or", "<cmd>echom &channel<cr>", { desc = "Repl", silent = true })

vim.g.slime_target = "neovim" -- must be set before loading slime

-- Works only on terminals created after slime was loaded:
vim.g.slime_menu_config = 1 -- choose interactively

vim.keymap.set("n", "<leader>oR", function() end, { desc = "No-op slime(repl)", silent = true })
