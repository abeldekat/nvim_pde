local Util = require("ak.util")
local enabled = true

require("treesitter-context").setup({ mode = "cursor", max_lines = 3 })

vim.keymap.set("n", "<leader>ut", function()
  local tsc = require("treesitter-context")
  tsc.toggle()
  enabled = not enabled
  if enabled then
    Util.info("Enabled treesitter context", { title = "Option" })
  else
    Util.warn("Disabled treesitter tontext", { title = "Option" })
  end
end, { desc = { "Toggle treesitter context" }, silent = true })
