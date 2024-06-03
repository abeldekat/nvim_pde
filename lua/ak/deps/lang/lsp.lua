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
      "folke/lazydev.nvim",
      "williamboman/mason-lspconfig.nvim",
      { source = "mrcjkb/rustaceanvim", checkout = "4.24.0" },
    },
  })
  require("ak.config.lang.diagnostics")
  require("ak.config.lang.lspconfig")

  add("j-hui/fidget.nvim")
  require("ak.config.lang.fidget")

  add("b0o/SchemaStore.nvim")
end
later(load)

if vim.fn.argc() > 0 then
  later(function() -- The lsp does not attach when directly opening a file:
    local ft = vim.bo.filetype
    if ft and ft ~= "oil" then
      vim.api.nvim_exec_autocmds("FileType", {
        modeline = false,
        pattern = vim.bo.filetype,
      })
    end
  end)
end
