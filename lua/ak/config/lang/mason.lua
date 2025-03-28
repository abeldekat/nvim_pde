local mason_ensure_installed = {
  "black", -- formatter python
  "codelldb", -- rust debugger
  "goimports", -- go formatter
  "gofumpt", -- go formatter
  "markdownlint-cli2", -- linter
  "markdown-toc", -- formatter
  "prettier",
  "shfmt", -- formatter
  "sqlfluff", -- formatter
  "stylua", -- formatter
}

-- Ensure lsp installed
local lsp_files = {}
vim.list_extend(lsp_files, vim.api.nvim_get_runtime_file("lsp/*", true))
vim.list_extend(lsp_files, vim.api.nvim_get_runtime_file("lua/ak/config/lang/with_lspconfig/*", true))
for _, v in ipairs(lsp_files) do -- by gpanders
  local name = vim.fn.fnamemodify(v, ":t:r")
  if not name == "rust-analyzer" then table.insert(mason_ensure_installed, name) end
end

require("mason").setup()

local mr = require("mason-registry")
local function trigger_filetype() -- possibly load newly installed LSP
  vim.api.nvim_exec_autocmds("FileType", {
    buffer = vim.api.nvim_get_current_buf(),
    modeline = false,
    data = {},
  })
end
mr:on("package:install:success", function() vim.defer_fn(trigger_filetype, 100) end)

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
