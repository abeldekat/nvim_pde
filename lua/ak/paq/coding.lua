local M = {}

local coding_spec = {
  "windwp/nvim-autopairs",
  --
  "LudoPinelli/comment-box.nvim",
  "JoosepAlviste/nvim-ts-context-commentstring",
  --
  "numToStr/Comment.nvim", -- the plugin itself creates the gc and gb mappings
  --
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "saadparwaiz1/cmp_luasnip",
  "hrsh7th/nvim-cmp",
  --
  "monaqa/dial.nvim",
  --
  "rafamadriz/friendly-snippets",
  "L3MON4D3/LuaSnip",
  "gbprod/substitute.nvim", -- substitute, exchange and multiply(not used often, not lazy)
  "kylechui/nvim-surround",
}

function M.spec()
  return coding_spec
end

function M.setup()
  require("ak.config.pairs") -- event
  require("ak.config.comment_box") -- keys
  require("ak.config.comment") -- keys
  require("ak.config.completion") -- event
  require("ak.config.dial") -- keys
  require("ak.config.snip") -- keys
  require("ak.config.substitute") -- keys
  require("ak.config.surround") -- keys, version = *
end

return M
