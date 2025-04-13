-- https://github.com/microsoft/vscode-json-languageservice
-- https://github.com/hrsh7th/vscode-langservers-extracted, html, css, json and eslint
-- Nvim-lspconfig name: jsonls
--
-- Install via aur:
-- git clone https://aur.archlinux.org/vscode-langservers-extracted.git
-- cd and makepkg -si, essentially doing a npm install
--
-- vscode-langservers-extracted /usr/bin/vscode-css-language-server
-- vscode-langservers-extracted /usr/bin/vscode-eslint-language-server
-- vscode-langservers-extracted /usr/bin/vscode-html-language-server
-- vscode-langservers-extracted /usr/bin/vscode-json-language-server
-- vscode-langservers-extracted /usr/bin/vscode-markdown-language-server
--
--
-- Can also be installed with npm i -g vscode-langservers-extracted
-- See also mason-registry, packages/json-lsp/package.yaml

return {
  -- Lazy-load schemastore when needed:
  before_init = function(_, config) -- used to be on_new_config using nvim-lspconfig
    config.settings.json.schemas = config.settings.json.schemas or {}
    vim.list_extend(config.settings.json.schemas, require("schemastore").json.schemas())
  end,
  settings = {
    json = {
      format = { enable = true },
      validate = { enable = true },
    },
  },
}
