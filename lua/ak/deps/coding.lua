local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

Util.has_mini_ai = true -- ai and textobjects with gen_treesitter...
if Util.has_mini_ai then later(function() require("ak.config.coding.mini_ai") end) end

Util.has_blink = true -- Testing blink
if Util.has_blink then -- 2 plugins, blink and friendly-snippets
  now(function()
    -- use a release tag to download pre-built binaries
    add({
      source = "saghen/blink.cmp",
      depends = {
        "rafamadriz/friendly-snippets",
      },
      checkout = "v0.5.1", -- check releases for latest tag
    })
    require("ak.config.coding.blink") -- includes snippets
  end)
end

later(function()
  -- luasnip, friendly-snippets, cmp and 4 sources: 7 plugins
  if not Util.has_blink then
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
  end

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
