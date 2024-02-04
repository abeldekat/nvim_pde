local mason_ensure_installed = {
  "markdownlint", -- linter
  "stylua", -- formatter
  "shfmt", -- formatter
  "black", -- formatter python
  "sql-formatter", -- formatter sql
  -- "debugpy", -- dap python
}
require("mason").setup()

local mr = require("mason-registry")
mr:on("package:install:success", function()
  vim.defer_fn(function()
    -- trigger FileType event to possibly load this newly installed LSP server
    vim.api.nvim_exec_autocmds("FileType", {
      buffer = vim.api.nvim_get_current_buf(),
      modeline = false,
    })
  end, 100)
end)
local function ensure_installed()
  for _, tool in ipairs(mason_ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then
      p:install()
    end
  end
end

ensure_installed()

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason", silent = true })
