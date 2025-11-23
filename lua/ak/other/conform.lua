-- vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" -- conform for gq

require('conform').setup({
  format_on_save = function() -- bufnr
    if Config.disable_autoformat then return end
    return { timeout_ms = 3000, lsp_format = 'fallback' } -- recommended: 5000
  end,
  formatters_by_ft = {
    css = { 'prettier' },
    go = { 'goimports', 'gofumpt' },
    html = { 'prettier' },
    javascript = { 'prettier' },
    json = { 'prettier' },
    jsonc = { 'prettier' },
    lua = { 'stylua' },
    markdown = { 'prettier' }, -- { "prettier", "markdownlint-cli2", "markdown-toc" }
    yaml = { 'prettier' },
  },
})

Config.toggle_conform = function()
  Config.disable_autoformat = not Config.disable_autoformat
  vim.notify('Auto-format ' .. (Config.disable_autoformat and 'off' or 'on'))
end
