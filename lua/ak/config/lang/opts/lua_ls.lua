return {
  server = {
    ---@type LazyKeysSpec[]
    -- keys = {},

    ---@type lspconfig.options
    ---@diagnostic disable-next-line: missing-fields
    settings = {
      Lua = {
        workspace = {
          checkThirdParty = false,
        },
        completion = {
          callSnippet = "Replace",
        },
      },
    },
  },

  -- you can do any additional lsp server setup here
  -- return true if you don't want this server to be setup with lspconfig
  ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
  setup = nil,
  -- {
  -- example to setup with typescript.nvim
  -- tsserver = function(_, opts)
  --   require("typescript").setup({ server = opts })
  --   return true
  -- end,
  -- },
}
