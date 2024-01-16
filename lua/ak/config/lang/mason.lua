local mason_ensure_installed = {
  "markdownlint", -- linter
  "stylua", -- formatter
  "shfmt", -- formatter
  "black", -- formatter python
  "sql-formatter", -- formatter sql
  -- "debugpy", -- dap python
}

---@type MasonSettings | {ensure_installed: string[]}
local opts = {
  ensure_installed = mason_ensure_installed,
}
require("mason").setup(opts)

local mr = require("mason-registry")
mr:on("package:install:success", function()
  vim.defer_fn(function()
    -- trigger FileType event to possibly load this newly installed LSP server
    require("lazy.core.handler.event").trigger({
      event = "FileType",
      buf = vim.api.nvim_get_current_buf(),
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
if mr.refresh then
  mr.refresh(ensure_installed)
else
  ensure_installed()
end

vim.keymap.set("n", "<leader>cm", "<cmd>Mason<cr>", { desc = "Mason", silent = true })
