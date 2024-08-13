-- Treesitter incremental selection: use leap
-- <C-Space> is for tmux.
vim.keymap.set({ "n", "x", "o" }, "gb", function() require("leap.treesitter").select() end)
