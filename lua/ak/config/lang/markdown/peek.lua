-- enabled = function()
--   if vim.fn.executable("deno") == 1 then
--     return true
--   end
--   require("lazyvim.util").warn({
--     "`peek.nvim` requires `deno` to be installed.\n",
--     "To hide this message, install `deno` or disable the `toppair/peek.nvim` plugin.",
--   }, { title = "LazyVim Extras `lang.markdown`" })
--   return false
-- end,
require("peek").setup({ theme = "light" })

-- ft = "markdown",
vim.keymap.set("n", "<leader>ck", function()
  local peek = require("peek")
  if peek.is_open() then
    peek.close()
  else
    peek.open()
  end
end, { desc = "Peek (Markdown Preview)", silent = true })
