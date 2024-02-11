require("spectre").setup({ open_cmd = "noswapfile vnew" })

vim.keymap.set(
  "n",
  "<leader>sr",
  function() require("spectre").open() end,
  { desc = "Replace in files (spectre)", silent = true }
)
