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
  { "gbprod/substitute.nvim", opt = true }, -- substitute, exchange and multiply(not used often, not lazy)
  { "kylechui/nvim-surround", opt = true }, -- TODO: version = *
  { "LudoPinelli/comment-box.nvim", opt = true },
  { "JoosepAlviste/nvim-ts-context-commentstring", opt = true },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/nvim-cmp",
}

function M.spec()
  return coding_spec
end

function M.setup()
  Util.paq.on_events(function()
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

  require("ak.config.completion") -- cannot lazyload
end

return M
