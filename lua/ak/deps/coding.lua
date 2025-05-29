-- Text editing...
local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local blink_version = "v1.3.1" -- nil builds from source

Util.use_mini_ai = true
-- Util.mini_completion_fuzzy_provider = "blink" -- default native fuzzy (see completeopt)
Util.completion = "mini" -- "blink"

local function blink()
  local function build(params)
    vim.notify("Building blink.cmp", vim.log.levels.INFO)
    local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
    if obj.code == 0 then
      vim.notify("Building blink.cmp done", vim.log.levels.INFO)
    else
      vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
    end
  end
  local source = "saghen/blink.cmp"
  local spec = { source = source, checkout = blink_version }
  if not blink_version then spec = { source = source, hooks = { post_install = build, post_checkout = build } } end
  add(spec)
end
local completion_providers = {
  blink = function() -- adds 7 ms to startuptime when using now()
    blink()
    require("ak.config.coding.blink_completion")
  end,
  mini = function()
    if Util.mini_completion_fuzzy_provider == "blink" then blink() end
    require("ak.config.coding.mini_completion")
  end,
}

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.config.coding.snippets")

  local completion_setup = completion_providers[Util.completion]
  if completion_setup then completion_setup() end

  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main" })
  require("ak.config.coding.textobjects_treesitter")

  if Util.use_mini_ai then require("ak.config.coding.ai") end
  require("ak.config.coding.align")
  require("ak.config.coding.move")
  require("ak.config.coding.operators")
  require("ak.config.coding.pairs")
  require("ak.config.coding.splitjoin")
  require("ak.config.coding.surround")

  add("monaqa/dial.nvim")
  require("ak.config.coding.dial")
end)
