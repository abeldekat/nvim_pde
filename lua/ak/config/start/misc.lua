local misc = require("mini.misc").setup() -- misc provides a make_global option...

-- Cursor
MiniMisc.setup_restore_cursor()
-- Terminal: misc.setup_termbg_sync() -- not working in tmux

vim.keymap.set("n", "<leader>uz", "<cmd>lua MiniMisc.zoom()<cr>", { desc = "Toggle zoom buffer", silent = true })
