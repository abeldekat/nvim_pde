local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add({
    source = "nvim-treesitter/nvim-treesitter",
    -- Use 'master' while monitoring updates in 'main'
    checkout = "master",
    monitor = "main",
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  })
  -- not in depends of treesitter due to plugin/nvim-treesitter-textobjects.vim:
  add("nvim-treesitter/nvim-treesitter-textobjects")
  require("ak.config.treesitter.treesitter")

  add("windwp/nvim-ts-autotag")
  require("ak.config.treesitter.autotag")

  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.treesitter.context")
end)
