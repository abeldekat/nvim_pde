--          ╭─────────────────────────────────────────────────────────╮
--          │            Contains plugins that modify code            │
--          │          The majority is loaded on InsertEnter          │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local M = {}

local coding_spec = {
  { "windwp/nvim-autopairs", opt = true },
  { "numToStr/Comment.nvim", opt = true },
  { "monaqa/dial.nvim", opt = true },
  { "rafamadriz/friendly-snippets", opt = true },
  { "L3MON4D3/LuaSnip", opt = true },
  { "gbprod/substitute.nvim", opt = true },
  { "kylechui/nvim-surround", opt = true },
  { "LudoPinelli/comment-box.nvim", opt = true },
  { "JoosepAlviste/nvim-ts-context-commentstring", opt = true },
  { "hrsh7th/cmp-nvim-lsp", opt = false },
  { "hrsh7th/cmp-buffer", opt = true },
  { "hrsh7th/cmp-path", opt = true },
  { "saadparwaiz1/cmp_luasnip", opt = true },
  { "hrsh7th/nvim-cmp", opt = false },
}

local function load_completion()
  vim.cmd.packadd("cmp-buffer")
  vim.cmd.packadd("cmp-path")
  vim.cmd.packadd("cmp_luasnip")

  -- in lspconfig: pcall(require, "cmp_nvim_lsp"):
  -- vim.cmd.packadd("cmp-nvim-lsp")
  -- vim.cmd.packadd("nvim-cmp")
  require("ak.config.completion")
end

function M.spec()
  return coding_spec
end

function M.setup()
  Util.paq.on_events(function()
    load_completion()

    vim.cmd("packadd nvim-autopairs")
    require("ak.config.pairs")

    vim.cmd("packadd friendly-snippets")
    vim.cmd("packadd LuaSnip")
    require("ak.config.snip")

    vim.cmd("packadd nvim-ts-context-commentstring")
    vim.cmd("packadd Comment.nvim")
    require("ak.config.comment")

    vim.cmd("packadd dial.nvim")
    require("ak.config.dial")

    vim.cmd("packadd substitute.nvim")
    require("ak.config.substitute")

    vim.cmd("packadd nvim-surround")
    require("ak.config.surround")
  end, "InsertEnter")

  Util.paq.on_keys(function()
    vim.cmd("packadd comment-box.nvim")
    require("ak.config.comment_box")
  end, { "<leader>bb", "<leader>bl" }, "Comment-box")
end

return M
