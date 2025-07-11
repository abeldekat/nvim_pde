local add, later = MiniDeps.add, MiniDeps.later
local use_hardtime_mini = true

later(function()
  require("ak.workflow.bracketed")
  require("ak.workflow.clue")
  if use_hardtime_mini then require("ak.workflow.hardtime_mini") end
  require("ak.workflow.files")
  require("ak.workflow.git")
  require("ak.workflow.jump2d")
  require("ak.workflow.diff")
  require("ak.workflow.pick")
  require("ak.workflow.visits") -- like harpoon, also uses mini.pick

  -- Other:
  add("stevearc/quicker.nvim")
  require("ak.workflow.quicker")
  add("akinsho/toggleterm.nvim")
  require("ak.workflow.toggleterm")
  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.workflow.context_treesitter")
end)
