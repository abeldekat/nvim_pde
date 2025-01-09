local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later -- local now = MiniDeps.now

-- Change the default values here for use in ak.config:
Util.has_mini_ai = true
Util.snippets = "mini"
Util.mini_snippets_standalone = true
Util.completion = "nvim-cmp"
-- Util.completion = "blink"

-- blink and friendly-snippets: 2 plugins
local function blink_cmp()
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
    depends = { "rafamadriz/friendly-snippets" },
    -- checkout = "0.8.1",
    hooks = { post_install = build_blink, post_checkout = build_blink },
  })
  require("ak.config.coding.blink_cmp")
end

-- cmp and 3 sources: 4 plugins
local function nvim_cmp()
  local cmp_depends = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  }
  if Util.snippets == "mini" and not Util.mini_snippets_standalone then
    table.insert(cmp_depends, "abeldekat/cmp-mini-snippets")
  end

  add({ source = "hrsh7th/nvim-cmp", depends = cmp_depends })
  require("ak.config.coding.nvim_cmp")
end

-- --> wait for upcoming snippet support
-- only when snippet support is removed from each lsp configuration
local function mini_cmp() require("ak.config.coding.mini_completion") end

later(function()
  if Util.snippets == "mini" then
    add("rafamadriz/friendly-snippets")
    require("ak.config.coding.mini_snippets")
  end

  if Util.completion == "nvim-cmp" then
    nvim_cmp()
  elseif Util.completion == "blink" then
    -- NOTE: Blink adds 7 ms to startuptime when using now().
    blink_cmp()
  elseif Util.completion == "mini" then
    mini_cmp()
  end

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
