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
    vim.cmd("LspStart") -- for each installed lsp, try to attach to the current buffer
  end, 100)
end)
local function ensure_installed()
  for _, tool in ipairs(mason_ensure_installed) do
    local p = mr.get_package(tool)
    if not p:is_installed() then p:install() end
  end
end

-- See mason-registry.init.lua, function M.refresh(cb)
-- The code below ensures that the mason-registry is only refreshed:
-- 1. On first install or when the plugin needs to be build
-- 2. When using Mason's commands
if not require("mason-registry.sources").is_installed() and mr.refresh then
  mr.refresh(ensure_installed)
else
  ensure_installed()
end

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason", silent = true })
