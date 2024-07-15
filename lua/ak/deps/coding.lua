local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

Util.has_mini_ai = true -- ai and textobjects with gen_treesitter...
if Util.has_mini_ai then later(function() require("ak.config.coding.mini_ai") end) end

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

  require("ak.config.coding.mini_align") -- using a selection...
  require("ak.config.coding.mini_basics") -- using a selection...
  -- require("ak.config.coding.mini_comment") -- now builtin
  require("ak.config.coding.mini_move")
  require("ak.config.coding.mini_operators")
  require("ak.config.coding.mini_pairs")
  require("ak.config.coding.mini_splitjoin")
  require("ak.config.coding.mini_surround")

  add("monaqa/dial.nvim")
  require("ak.config.coding.dial")
  -- add("folke/ts-comments.nvim")
  -- require("ak.config.coding.ts-comments")
end)
