local Util = require("ak.util")
local opts = {
  name = {
    "venv",
    ".venv",
    "env",
    ".env",
  },
}
if Util.has("nvim-dap-python") then opts.dap_enabled = true end
require("venv-selector").setup(opts)

vim.keymap.set("n", "<leader>cv", "<cmd>:VenvSelect<cr>", { desc = "Venv selector", silent = true })
