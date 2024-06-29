local misc = require("mini.misc")
misc.setup_restore_cursor()
vim.keymap.set("n", "<leader>uz", function() misc.zoom() end, { desc = "Toggle zoom buffer", silent = true })
