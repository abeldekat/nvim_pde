local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = require("ak.util").opened_with_arguments() and MiniDeps.now or later

now_if_args(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  })
  require("ak.config.treesitter.treesitter")
end)

later(function()
  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", checkout = "main" })
  require("ak.config.treesitter.textobjects")
  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.treesitter.context")
end)
