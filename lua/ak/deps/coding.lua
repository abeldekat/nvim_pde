local Util = require("ak.util")
local MiniDeps = require("mini.deps")
-- local now = MiniDeps.now
local add, later = MiniDeps.add, MiniDeps.later

Util.has_mini_ai = true -- ai and textobjects with gen_treesitter...
Util.has_blink = true -- switched to blink, in beta. Keep cmp around

local function blink()
  add({ -- 2 plugins, blink and friendly-snippets
    source = "saghen/blink.cmp",
    depends = {
      "rafamadriz/friendly-snippets",
    },
    checkout = "v0.7.5",
  })
  require("ak.config.coding.blink") -- includes snippets
end

local function cmp()
  -- luasnip, friendly-snippets, cmp and 4 sources: 7 plugins
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
  require("ak.config.coding.cmp")
end

if Util.has_blink then -- NOTE: Blink adds 7 ms to startuptime using now().
  later(function() blink() end)
else
  later(function() cmp() end)
end

later(function()
  if Util.has_mini_ai then require("ak.config.coding.mini_ai") end

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
end)
