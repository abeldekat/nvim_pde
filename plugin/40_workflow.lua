local add, later = MiniDeps.add, MiniDeps.later
local use_hardtime_mini = true
local use_leap = true

later(function()
  -- Branch "keep_conceallevel" -> Issue 243, PR 270
  -- Branch "label_at_first_match_char" -> Issue 220, 271
  -- Branch "ak" -> Leap main + PR's
  add({ source = "abeldekat/leap.nvim", checkout = "ak" }) -- ({ source = "ggandor/leap.nvim" })
  if use_leap then
    require("ak.workflow.leap")
  else
    require("ak.workflow.leap_treesitter") -- to be replaced by mini.hierarchy, see issue 1818
    require("ak.workflow.jump2d")
  end

  -- Mini:
  require("ak.workflow.bracketed")
  require("ak.workflow.clue")
  if use_hardtime_mini then require("ak.workflow.hardtime_mini") end
  require("ak.workflow.files")
  require("ak.workflow.git")
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
