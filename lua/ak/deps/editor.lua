local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local use_hardtime = true --  mini.keymap instead of hardtime...

local files_now_or_later = Util.opened_with_dir_argument() and now or later
files_now_or_later(function() require("ak.config.editor.files") end)

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
