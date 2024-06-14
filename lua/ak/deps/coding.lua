local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

-- Lazy loading benefit: +-5 ms
later(function()
  local function make_jsregexp(path)
    vim.cmd("lcd " .. path)
    vim.cmd("!make -s install_jsregexp")
    vim.cmd("lcd -")
    Util.info("luasnip: cannot rm is not an error!")
  end
  add({
    source = "L3MON4D3/LuaSnip",
    hooks = {
      post_install = function(params) make_jsregexp(params.path) end,
      post_checkout = function(params) make_jsregexp(params.path) end,
    },
    depends = { "rafamadriz/friendly-snippets" },
  })
  add({
    source = "hrsh7th/nvim-cmp",
    depends = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Native snippets:
      -- "rafamadriz/friendly-snippets",
      -- "garymjr/nvim-snippets",

      -- LuaSnip:
      "saadparwaiz1/cmp_luasnip",
    },
  })
  require("ak.config.coding.cmp") -- includes snippets

  add("windwp/nvim-autopairs")
  require("ak.config.coding.autopairs")
  add("folke/ts-comments.nvim")
  require("ak.config.coding.ts-comments")

  -- require("ak.config.coding.mini_comment") -- now builtin
  require("ak.config.coding.mini_ai") -- testing...
  require("ak.config.coding.mini_basics") -- copied a selection...
  require("ak.config.coding.mini_surround")
  require("ak.config.coding.mini_operators")
  require("ak.config.coding.mini_move")

  add("monaqa/dial.nvim")
  require("ak.config.coding.dial")

  local spec_comment_box = "LudoPinelli/comment-box.nvim"
  register(spec_comment_box)
  Util.defer.on_keys(function()
    now(function()
      add(spec_comment_box)
      require("ak.config.coding.comment_box")
    end)
  end, "<leader>bL", "Load comment-box")
end)
