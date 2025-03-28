-- https://github.com/microsoft/vscode-json-languageservice
-- Using mason.
-- Mason name: json-lsp. Nvim-lspconfig name: json_ls

return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  -- Lazy-load schemastore when needed:
  before_init = function(_, config) -- used to be on_new_config using nvim-lspconfig
    config.settings.json.schemas = config.settings.json.schemas or {}
    vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
  end,
  init_options = {
    provideFormatter = true,
  },
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}
