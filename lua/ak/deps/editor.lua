local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

local use_hardtime = true -- using mini.keymap...

now(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Explorer                        │
  --          ╰─────────────────────────────────────────────────────────╯
  local function add_explorer() require("ak.config.editor.files") end
  -- stylua: ignore
  if Util.opened_with_dir_argument() then add_explorer() else later(add_explorer) end
end)

later(function()
  add("ggandor/leap.nvim")
  require("ak.config.editor.leap")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                          Mini                           │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.editor.clue")
  require("ak.config.editor.cursorword")
  if use_hardtime then require("ak.config.editor.hardtime") end
  require("ak.config.editor.hipatterns")
  require("ak.config.editor.git")
  require("ak.config.editor.diff")
  require("ak.config.editor.pick")
  require("ak.config.editor.visits") -- marks like grapple.nvim/harpoon, uses mini.pick

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Quickfix                        │
  --          ╰─────────────────────────────────────────────────────────╯
  local spec_bqf = {
    source = "kevinhwang91/nvim-bqf",
    depends = { { source = "yorickpeterse/nvim-pqf" } },
  }
  add(spec_bqf)
  require("ak.config.editor.quickfix")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Terminal                        │
  --          ╰─────────────────────────────────────────────────────────╯
  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")
end)
