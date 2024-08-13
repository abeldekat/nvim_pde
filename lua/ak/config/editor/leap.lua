-- Treesitter incremental selection: use leap
-- <C-Space> is for tmux. Use tmux's default prefix
vim.keymap.set({ "n", "x", "o" }, "<C-b>", function() require("leap.treesitter").select() end)
