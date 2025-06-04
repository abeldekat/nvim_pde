local enabled = true

require("treesitter-context").setup({ mode = "cursor", max_lines = 3 })

vim.keymap.set("n", "<leader>ut", function()
  local tsc = require("treesitter-context")
  tsc.toggle()
  enabled = not enabled
  if enabled then
    vim.notify("Enabled treesitter context", vim.log.levels.INFO)
  else
    vim.notify("Disabled treesitter context", vim.log.levels.WARN)
  end
end, { desc = "Toggle treesitter context", silent = true })
