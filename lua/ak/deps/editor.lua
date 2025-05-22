local MiniDeps = require("mini.deps")
local add, later = MiniDeps.add, MiniDeps.later
local now_if_dir_arg = require("ak.util").opened_with_dir_argument() and MiniDeps.now or later
local use_hardtime = true --  mini.keymap instead of hardtime...

now_if_dir_arg(function() require("ak.config.editor.files") end)

later(function()
  -- Leap:
  add("ggandor/leap.nvim")
  require("ak.config.editor.leap")

  -- Mini:
  require("ak.config.editor.clue")
  require("ak.config.editor.cursorword")
  if use_hardtime then require("ak.config.editor.hardtime") end
  require("ak.config.editor.hipatterns")
  require("ak.config.editor.git")
  require("ak.config.editor.diff")
  require("ak.config.editor.pick")
  require("ak.config.editor.visits") -- like harpoon, also uses mini.pick

  -- Other:
  add({ source = "kevinhwang91/nvim-bqf", depends = { { source = "yorickpeterse/nvim-pqf" } } })
  require("ak.config.editor.quickfix")
  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")
end)
