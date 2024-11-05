local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local register = Util.deps.register

local extra_lazyvim_support = false
if extra_lazyvim_support then later(function()
  register("folke/lazy.nvim")
  register("LazyVim/LazyVim")
end) end

local function lsp()
  local build_mason = function()
    later(function() vim.cmd("MasonUpdate") end)
  end
  add({
    source = "williamboman/mason.nvim",
    hooks = { post_install = build_mason, post_checkout = build_mason },
  })
  require("ak.config.lang.mason")

  register("Bilal2453/luvit-meta") -- does not need to be loaded
  register("folke/lazydev.nvim")
  Util.defer.on_events(function()
    add("folke/lazydev.nvim")
    require("ak.config.lang.lazydev")
  end, "FileType", "lua")

  add({
    source = "neovim/nvim-lspconfig",
    depends = {
      "folke/lazydev.nvim",
      "williamboman/mason-lspconfig.nvim",
      { source = "mrcjkb/rustaceanvim", checkout = "v5.13.1" },
    },
  })
  require("ak.config.lang.diagnostics")
  require("ak.config.lang.lspconfig")

  add("j-hui/fidget.nvim")
  require("ak.config.lang.fidget")

  add("b0o/SchemaStore.nvim")
end

later(lsp)
if Util.opened_with_arguments() then
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
