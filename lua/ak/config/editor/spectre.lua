-- Not actively used...
-- Last commit downloaded: ddd7383e856a7c939cb4f5143278fe041bbb8cb9
require("spectre").setup({ open_cmd = "noswapfile vnew" })

vim.keymap.set(
  "n",
  "<leader>cR",
  function() require("spectre").open() end,
  { desc = "Replace in files (spectre)", silent = true }
)
