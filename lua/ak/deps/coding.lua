local Util = require("ak.util")
local register = Util.deps.register
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local blink_version = "v1.1.1" -- nil

Util.use_mini_ai = true

-- Util.completion = "blink"
Util.completion = "mini"
-- Util.mini_completion_fuzzy_provider = "blink" -- defaults to native fuzzy (see completeopt)

local function blink(cb)
  local function build(params)
    vim.notify("Building blink.cmp", vim.log.levels.INFO)
    local obj = vim.system({ "cargo", "build", "--release" }, { cwd = params.path }):wait()
    if obj.code == 0 then
      vim.notify("Building blink.cmp done", vim.log.levels.INFO)
    else
      vim.notify("Building blink.cmp failed", vim.log.levels.ERROR)
    end
  end

  if blink_version then
    cb({ source = "saghen/blink.cmp", checkout = blink_version })
    return
  end

  cb({ source = "saghen/blink.cmp", hooks = { post_install = build, post_checkout = build } })
end

local function blink_completion() -- blink adds 7 ms to startuptime when using now()
  blink(add)
  require("ak.config.coding.blink_completion")
end

local function mini_completion()
  if Util.mini_completion_fuzzy_provider == "blink" then
    blink(add)
  else
    blink(register)
  end
  require("ak.config.coding.mini_completion")
end

local completion_providers = {
  blink = blink_completion,
  mini = mini_completion,
}

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.config.coding.snippets")

  local completion_setup = completion_providers[Util.completion]
  if completion_setup then completion_setup() end

  if Util.use_mini_ai then require("ak.config.coding.ai") end

  require("ak.config.coding.align")
  require("ak.config.coding.bracketed")
  -- require("ak.config.coding.comment") -- now builtin
  require("ak.config.coding.move")
  require("ak.config.coding.operators")
  require("ak.config.coding.pairs")
  require("ak.config.coding.splitjoin")
  require("ak.config.coding.surround")

  add("monaqa/dial.nvim")
  require("ak.config.coding.dial")
end)
