vim.keymap.set(
  "n",
  "<leader>uz",
  function() require("mini.misc").zoom() end,
  { desc = "Toggle zoom buffer", silent = true }
)
