require("persistence").setup({ options = vim.opt.sessionoptions:get() })
vim.keymap.set("n", "<leader>ms", function()
  require("persistence").load()
end, { desc = "Restore session", silent = true })

vim.keymap.set("n", "<leader>mL", function()
  require("persistence").load({ last = true })
end, { desc = "Restore last session", silent = true })

vim.keymap.set("n", "<leader>mD", function()
  require("persistence").stop()
end, { desc = "Don't save current session", silent = true })
