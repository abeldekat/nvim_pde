local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
-- local now = MiniDeps.now

Util.has_mini_ai = true -- coordinate mini.ai and textobjects with gen_treesitter...
Util.snippets = "luasnip"
Util.completion = "nvim-cmp"

local function luasnip()
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
  require("ak.config.coding.luasnip")
end

local function blink_cmp()
  -- 2 plugins, blink and friendly-snippets
  local function build_blink(params)
    vim.notify("Building blink.cmp", vim.log.levels.INFO)
    local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
    if obj.code == 0 then
      vim.notify("Building blink.cmp done", vim.log.levels.INFO)
    else
      vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
    end
  end

  add({
    source = "saghen/blink.cmp",
    depends = {
      "rafamadriz/friendly-snippets",
    },
    -- checkout = "0.8.1",
    hooks = {
      post_install = build_blink,
      post_checkout = build_blink,
    },
  })
  require("ak.config.coding.blink_cmp") -- includes snippets
end

local function nvim_cmp()
  -- luasnip, friendly-snippets, cmp and 4 sources: 7 plugins
  local cmp_depends = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  }

  if Util.snippets == "luasnip" then
    luasnip()
    table.insert(cmp_depends, "saadparwaiz1/cmp_luasnip")
  end

  add({
    source = "hrsh7th/nvim-cmp",
    depends = cmp_depends,
  })
  require("ak.config.coding.nvim_cmp")
end

local function mini_cmp() -- not in use, wait for snippet support
  add("rafamadriz/friendly-snippets")
  require("ak.config.coding.mini_completion")
end

if Util.completion == "blink" then -- NOTE: Blink adds 7 ms to startuptime using now().
  later(function() blink_cmp() end)
elseif Util.completion == "nvim-cmp" then
  later(function() nvim_cmp() end)
elseif Util.completion == "mini" then
  later(function() mini_cmp() end)
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
