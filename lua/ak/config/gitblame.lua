vim.g.gitblame_enabled = 0

---@diagnostic disable-next-line: missing-fields
require("gitblame").setup({
  date_format = "%x",
})

vim.keymap.set("n", "<leader>gt", function()
  vim.cmd("GitBlameToggle")
end, { desc = "Toggle gitblame", silent = true })
