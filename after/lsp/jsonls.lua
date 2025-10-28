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
