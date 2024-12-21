local Util = require("ak.util")
local MiniDeps = require("mini.deps")
-- local now = MiniDeps.now
local add, later = MiniDeps.add, MiniDeps.later

Util.has_mini_ai = true -- ai and textobjects with gen_treesitter...

-- crust of rust declarative macros:
-- let mut y = Some(42);
-- let x: Vec<u32> = avec![42; 2];
-- > Now, change 42 in avec to y and type .take: No completion in blink 0.8.0, does work in 0.7.6
Util.has_blink = false -- switched to blink, in beta. Keep cmp around

local function blink()
  -- local function build_blink(params)
  --   vim.notify("Building blink.cmp", vim.log.levels.INFO)
  --   local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
  --   if obj.code == 0 then
  --     vim.notify("Building blink.cmp done", vim.log.levels.INFO)
  --   else
  --     vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
  --   end
  -- end

  add({ -- 2 plugins, blink and friendly-snippets
    source = "saghen/blink.cmp",
    depends = {
      "rafamadriz/friendly-snippets",
    },
    checkout = "v0.7.6",
    -- hooks = {
    --   post_install = build_blink,
    --   post_checkout = build_blink,
    -- },
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
