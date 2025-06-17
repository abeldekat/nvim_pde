local Settings = require("akshared.settings")
local add, later = MiniDeps.add, MiniDeps.later
local H = {}

Settings.use_mini_ai = true

later(function()
  add("rafamadriz/friendly-snippets")
  require("ak.editing.snippets")
  require("ak.editing.completion")

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
