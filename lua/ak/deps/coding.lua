local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

-- Lazy loading benefit: +-5 ms
later(function()
  add({
    source = "hrsh7th/nvim-cmp",
    depends = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
  })
  require("ak.config.coding.cmp")

  add("windwp/nvim-autopairs")
  require("ak.config.coding.autopairs")

  local function make_jsregexp(path)
    vim.cmd("lcd " .. path)
    vim.cmd("!make -s install_jsregexp")
    vim.cmd("lcd -")
    Util.info("NOTE: luasnip: cannot rm is not an error")
  end
  add({
    source = "L3MON4D3/LuaSnip",
    hooks = {
      post_install = function(params) make_jsregexp(params.path) end,
      post_checkout = function(params) make_jsregexp(params.path) end,
    },
    depends = { "rafamadriz/friendly-snippets" },
  })
  require("ak.config.coding.LuaSnip")

  add({ source = "numToStr/Comment.nvim", depends = { "JoosepAlviste/nvim-ts-context-commentstring" } })
  require("ak.config.coding.comment")

  add("monaqa/dial.nvim")
  require("ak.config.coding.dial")

  add("gbprod/substitute.nvim")
  require("ak.config.coding.substitute")

  add("kylechui/nvim-surround")
  require("ak.config.coding.surround")

  later(function() register("LudoPinelli/comment-box.nvim") end)
  Util.defer.on_keys(function()
    now(function()
      add("LudoPinelli/comment-box.nvim")
      require("ak.config.coding.comment_box")
    end)
  end, "<leader>bL", "Load comment-box")
end)
