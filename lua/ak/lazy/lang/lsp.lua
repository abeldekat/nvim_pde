local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

return {
  {
    "neovim/nvim-lspconfig",
    event = lazyfile(),
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
    end,
  },
  { -- yaml schema support
    "b0o/SchemaStore.nvim",
    lazy = true,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = function()
      require("ak.config.fidget")
    end,
  },
}
