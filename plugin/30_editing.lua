local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local H = {}

-- Util.mini_completion_fuzzy_provider = "blink" -- default native fuzzy (see completeopt)
Util.completion = "mini" -- "blink"
Util.use_mini_ai = true

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.config.editing.snippets")

  local completion_setup = H.completion_providers[Util.completion]
  if completion_setup then completion_setup() end

  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main" })
  require("ak.config.editing.textobjects_treesitter")

  if Util.use_mini_ai then require("ak.config.editing.ai") end
  require("ak.config.editing.align")
  require("ak.config.editing.move")
  require("ak.config.editing.operators")
  require("ak.config.editing.pairs")
  require("ak.config.editing.splitjoin")
  require("ak.config.editing.surround")

  add("monaqa/dial.nvim")
  require("ak.config.editing.dial")
end)

H.blink_version = "v1.3.1" -- nil builds from source

H.completion_providers = {
  blink = function() -- adds 7 ms to startuptime when using now()
    H.blink()
    require("ak.config.editing.blink_completion")
  end,
  mini = function()
    if Util.mini_completion_fuzzy_provider == "blink" then H.blink() end
    require("ak.config.editing.mini_completion")
  end,
}

H.blink = function()
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
  local spec = { source = source, checkout = H.blink_version }
  if not H.blink_version then spec = { source = source, hooks = { post_install = build, post_checkout = build } } end
  add(spec)
end
