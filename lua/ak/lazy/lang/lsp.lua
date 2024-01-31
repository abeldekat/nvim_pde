-- local lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }
local Util = require("ak.util")

return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy", -- lazyfile
    dependencies = {
      "folke/neoconf.nvim",
      "folke/neodev.nvim",
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        config = function()
          require("ak.config.lang.mason")
        end,
      },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("ak.config.lang.lspconfig")

      -- On VeryLazy, the lsp does not attach when directly opening a file:
      if not (Util.opened_without_arguments() or Util.opened_with_dir_argument()) then
        vim.cmd("LspStart")
      end
    end,
  },
  { "b0o/SchemaStore.nvim" }, -- yaml schema support
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("ak.config.fidget")
    end,
  },
}
