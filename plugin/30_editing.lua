local Settings = require("akshared.settings")
local add, later = MiniDeps.add, MiniDeps.later
local H = {}

-- Settings.mini_completion_fuzzy_provider = "blink" -- default native fuzzy (see completeopt)
Settings.completion = "mini" -- "blink"
Settings.use_mini_ai = true

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.editing.snippets")

  local completion_setup = H.completion_providers[Settings.completion]
  if completion_setup then completion_setup() end

  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main" })
  require("ak.editing.textobjects_treesitter")

  if Settings.use_mini_ai then require("ak.editing.ai") end
  require("ak.editing.align")
  require("ak.editing.move")
  require("ak.editing.operators")
  require("ak.editing.pairs")
  require("ak.editing.splitjoin")
  require("ak.editing.surround")

  add("monaqa/dial.nvim")
  require("ak.editing.dial")
end)

H.blink_version = "v1.3.1" -- nil builds from source

H.completion_providers = {
  blink = function() -- adds 7 ms to startuptime when using now()
    H.blink()
    require("ak.editing.blink_completion")
  end,
  mini = function()
    if Settings.mini_completion_fuzzy_provider == "blink" then H.blink() end
    require("ak.editing.mini_completion")
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
