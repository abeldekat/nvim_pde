local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

local function load()
  local build_mason = function()
    later(function() vim.cmd("MasonUpdate") end)
  end
  add({
    source = "williamboman/mason.nvim",
    hooks = { post_install = build_mason, post_checkout = build_mason },
  })
  require("ak.config.lang.mason")

  add({
    source = "neovim/nvim-lspconfig",
    depends = {
      "folke/neoconf.nvim",
      "folke/neodev.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  })
  require("ak.config.lang.lspconfig")

  add("b0o/SchemaStore.nvim")
end

later(load)
later(function()
  -- The lsp does not attach when directly opening a file:
  if not (Util.opened_without_arguments() or Util.opened_with_dir_argument()) then vim.cmd("LspStart") end
end)
