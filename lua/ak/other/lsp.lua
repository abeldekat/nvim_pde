vim.lsp.enable({
  'basedpyright',
  'bashls',
  -- 'fennel_ls',
  'gopls',
  'jsonls',
  'lua_ls',
  'marksman',
  'ruff',
  'rust_analyzer',
  'taplo',
  'texlab',
  'yamlls',
})

Config.toggle_hints = function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end
