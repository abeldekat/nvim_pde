local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

local function lsp()
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
      "williamboman/mason-lspconfig.nvim",
      { source = "mrcjkb/rustaceanvim", checkout = "v5.25.1" },
    },
  })
  require("ak.config.lang.lspconfig")

  -- add("j-hui/fidget.nvim")
  -- require("fidget").setup({})

  add("b0o/SchemaStore.nvim")
end

later(lsp)
if Util.opened_with_arguments() then
  later(function() -- The lsp does not attach when directly opening a file:
    local ft = vim.bo.filetype
    if ft and ft ~= "minifiles" then
      vim.api.nvim_exec_autocmds("FileType", {
        modeline = false,
        pattern = vim.bo.filetype,
      })
    end
  end)
end
