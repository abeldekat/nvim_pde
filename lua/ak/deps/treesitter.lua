local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local now = MiniDeps.now

local function load_treesitter()
  local ts_spec = { -- monitor = "main", -- Use 'master' while monitoring updates in 'main'
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "master",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  }
  add(ts_spec)
  require("ak.config.treesitter.treesitter")
end

if Util.opened_without_arguments() then
  later(load_treesitter)
else -- load treesitter early when opening a file from the cmdline
  now(load_treesitter)
end

later(function()
  add("nvim-treesitter/nvim-treesitter-textobjects")
  require("ak.config.treesitter.textobjects")

  add("windwp/nvim-ts-autotag")
  require("ak.config.treesitter.autotag")

  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.treesitter.context")
end)
