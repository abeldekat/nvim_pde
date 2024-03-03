local Util = require("ak.util")
return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy", -- lazyfile
    dependencies = {
      {
        "williamboman/mason.nvim",
        build = ":MasonUpdate",
        config = function() require("ak.config.lang.mason") end,
      },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("ak.config.lang.diagnostics")
      require("ak.config.lang.lspconfig")

      -- On VeryLazy, the lsp does not attach when directly opening a file:
      if Util.opened_with_file_argument() then
        vim.schedule(function() vim.cmd("LspStart") end) --
      end
    end,
  },

  { "b0o/SchemaStore.nvim" }, -- yaml schema support

  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function() require("ak.config.lang.fidget") end,
  },
}
