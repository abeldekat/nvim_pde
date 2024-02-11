require("peek").setup({ theme = "light" })

vim.keymap.set("n", "<leader>ck", function()
  local peek = require("peek")
  if peek.is_open() then
    peek.close()
  else
    peek.open()
  end
end, { desc = "Peek (Markdown Preview)", silent = true })
