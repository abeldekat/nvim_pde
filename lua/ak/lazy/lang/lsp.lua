return {
  {
    "neovim/nvim-lspconfig",
    event = "LazyFile",
    dependencies = {
      "folke/neoconf.nvim",
      "folke/neodev.nvim",
      {
        "williamboman/mason.nvim",
        cmd = "Mason", -- keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        config = function()
          require("ak.config.lang.mason")
        end,
      },
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("ak.config.lang.lspconfig")
    end,
  },
  { -- yaml schema support
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is old
  },
}