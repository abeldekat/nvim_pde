local misc = require("mini.misc")
misc.setup() -- misc provides a make_global option...

-- Cursor
misc.setup_restore_cursor()

-- Terminal: misc.setup_termbg_sync() -- not working in tmux

-- Zoom
vim.keymap.set("n", "<leader>uz", function() misc.zoom() end, { desc = "Toggle zoom buffer", silent = true })
