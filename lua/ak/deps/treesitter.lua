local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local now = MiniDeps.now

local function treesitter()
  local ts_spec = {
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "master",
    hooks = { post_checkout = function() vim.cmd("TSUpdate") end },
  }
  add(ts_spec)
  require("ak.config.treesitter.treesitter")
end
-- stylua: ignore
if Util.opened_with_arguments() then now(treesitter) else later(treesitter) end

later(function()
  add("nvim-treesitter/nvim-treesitter-textobjects")
  require("ak.config.treesitter.textobjects")

  add("windwp/nvim-ts-autotag")
  require("ak.config.treesitter.autotag")

  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.treesitter.context")
end)
