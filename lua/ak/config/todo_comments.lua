require("todo-comments").setup()

local keys = vim.keymap.set

keys("n", "]t", function()
  require("todo-comments").jump_next()
end, { desc = "Next todo comment", silent = true })
keys("n", "[t", function()
  require("todo-comments").jump_prev()
end, { desc = "Previous todo comment", silent = true })
keys("n", "<leader>xt", "<cmd>TodoTrouble<cr>", { desc = "Todo (trouble)", silent = true })
keys(
  "n",
  "<leader>xT",
  "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",
  { desc = "Todo/Fix/Fixme (trouble)", silent = true }
)
keys("n", "<leader>st", "<cmd>TodoTelescope<cr>", { desc = "Todo", silent = true })
keys("n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", { desc = "Todo/Fix/Fixme", silent = true })
