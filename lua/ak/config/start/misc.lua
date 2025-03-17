local misc = require("mini.misc")
misc.setup() -- misc provides a make_global option...

-- Cursor
misc.setup_restore_cursor()

-- Terminal: misc.setup_termbg_sync() -- not working in tmux

-- Zoom
local zoom = function() misc.zoom(0, { title = "zoom", border = "double" }) end
vim.keymap.set("n", "<leader>uz", zoom, { desc = "Toggle zoom buffer", silent = true })
