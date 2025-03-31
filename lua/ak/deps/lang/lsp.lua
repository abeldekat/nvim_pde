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
  add({ source = "mrcjkb/rustaceanvim", checkout = "v5.25.2" })

  add("b0o/SchemaStore.nvim")
  add("neovim/nvim-lspconfig")

  require("ak.config.lang.mason")
  require("ak.config.lang.lsp")
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
