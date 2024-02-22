local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
later(function()
  local ts_spec = {
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "master",
    -- -- Use 'master' while monitoring updates in 'main'
    -- monitor = "main",
    -- Perform action after every checkout
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  }
  add({ source = "nvim-treesitter/nvim-treesitter-textobjects", depends = { ts_spec } })
  require("ak.config.treesitter.treesitter")
end)
later(function()
  add("windwp/nvim-ts-autotag")
  require("ak.config.treesitter.autotag")

  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.treesitter.context")
end)
