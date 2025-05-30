local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local use_hardtime_mini = true
local use_leap = false

later(function()
  add({ source = "ggandor/leap.nvim" })
  if use_leap then
    require("ak.config.workflow.leap")
  else
    require("ak.config.workflow.leap_treesitter") -- to be replaced by mini.hierarchy, see issue 1818
    require("ak.config.workflow.jump2d")
  end

  -- Mini:
  require("ak.config.workflow.bracketed")
  require("ak.config.workflow.clue")
  if use_hardtime_mini then require("ak.config.workflow.hardtime_mini") end
  require("ak.config.workflow.files")
  require("ak.config.workflow.git")
  require("ak.config.workflow.diff")
  require("ak.config.workflow.pick")
  require("ak.config.workflow.visits") -- like harpoon, also uses mini.pick

  -- Other:
  add("stevearc/quicker.nvim")
  require("ak.config.workflow.quicker")
  add("akinsho/toggleterm.nvim")
  require("ak.config.workflow.toggleterm")
  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.workflow.context_treesitter")
end)
