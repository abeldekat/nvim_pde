local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

-- Change the default values here for use in ak.config:
Util.use_mini_ai = true
Util.snippets_standalone = true
Util.completion = "mini"
-- Util.completion = "cmp"
-- Util.completion = "blink"
-- Util.completion = "none"

-- Blink adds 7 ms to startuptime when using now():
local function blink_completion()
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
    checkout = "v1.0.0",
    -- hooks = { post_install = build_blink, post_checkout = build_blink },
  })
  require("ak.config.coding.blink_completion")
end

-- mini-deps-snap: ["nvim-cmp"] = "c27370703e798666486e3064b64d59eaf4bdc6d5",
local function cmp_completion()
  local cmp_depends = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
  }
  if not Util.snippets_standalone then table.insert(cmp_depends, "abeldekat/cmp-mini-snippets") end

  add({ source = "hrsh7th/nvim-cmp", depends = cmp_depends })
  require("ak.config.coding.cmp_completion")
end

local function mini_completion()
  --
  require("ak.config.coding.mini_completion")
end

local completion_plugins = {
  mini = mini_completion,
  cmp = cmp_completion,
  blink = blink_completion,
}

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.config.coding.snippets")

  local completion_setup = completion_plugins[Util.completion]
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
