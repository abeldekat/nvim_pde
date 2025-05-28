local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local use_hardtime_mini = true
local use_leap = false

later(function()
  add({ source = "ggandor/leap.nvim" })
  if use_leap then
    require("ak.config.editor.leap")
  else
    require("ak.config.editor.leap_treesitter") -- to be replaced by mini.hierarchy, see issue 1818
    require("ak.config.editor.jump2d")
  end

  -- Mini:
  require("ak.config.editor.clue")
  require("ak.config.editor.cursorword")
  if use_hardtime_mini then require("ak.config.editor.hardtime_mini") end
  require("ak.config.editor.files")
  require("ak.config.editor.hipatterns")
  require("ak.config.editor.git")
  require("ak.config.editor.diff")
  require("ak.config.editor.pick")
  require("ak.config.editor.visits") -- like harpoon, also uses mini.pick

  -- Other:
  add("stevearc/quicker.nvim")
  require("ak.config.editor.quicker")
  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")
  add("nvim-treesitter/nvim-treesitter-context")
  require("ak.config.editor.context_treesitter")
end)
