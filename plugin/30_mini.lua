local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

now(function()
  -- NOTE: MiniMax activates statusline  on `now` before tabline
  vim.o.statusline = " " -- wait till statusline plugin is loaded
  -- vim.cmd("colorscheme miniwinter") -- see 29_color.lua

  require("ak.mini.basics")
  require("ak.mini.icons")
end)
now_if_args(function() require("ak.mini.misc") end)
now(function()
  require("ak.mini.notify")
  require("mini.sessions").setup()
  if vim.fn.argc(-1) == 0 then require("ak.mini.starter") end
  -- require("mini.tabline").setup()
end)

later(function()
  require("ak.mini.statusline")
  require("mini.extra").setup()
  require("ak.mini.ai")
  require("mini.align").setup()
  -- require("mini.animate").setup()
  require("mini.bracketed").setup()
  require("mini.bufremove").setup()
  require("ak.mini.clue")
  -- require("mini.colors").setup()
  -- require("mini.comment").setup()
  -- TODO: Restore ctrl k with mini.keymap, and why is omni cleaner
  -- TODO: Completefunc to use ctrl-o to temporarily escape to normal mode. See mini discussions #1736
  require("ak.mini.completion")
  -- require("mini.cursorword").setup()
  require("mini.diff").setup()
  require("ak.mini.files")
  require("mini.git").setup()
  -- TODO: Colored todos
  require("ak.mini.hipatterns")
  require("mini.indentscope").setup()
  require("mini.jump").setup()
  require("ak.mini.jump2d") -- I like the se mapping
  require("ak.mini.keymap")
  -- TODO: Setup on demand
  require("ak.mini.map")
  require("mini.move").setup()

  require("mini.operators").setup()
  -- Discussion 1835 duplicate and comment:
  vim.keymap.set("n", "gCC", "gmmgcck", { remap = true, desc = "Duplicate and comment line" })
  -- Skipped mappings to swap:
  -- vim.keymap.set("n", "(", "gxiagxila", { remap = true, desc = "Swap arg left" })
  -- vim.keymap.set("n", ")", "gxiagxina", { remap = true, desc = "Swap arg right" })

  -- TODO: Extra pickers
  -- TODO: Color picker make sure personal color config is loaded
  require("mini.pick").setup()
  require("ak.mini.snippets")
  -- TODO: Setup on demand
  require("mini.splitjoin").setup()
  require("mini.surround").setup() -- `sa sd sr sf sF sh sn`
  require("mini.trailspace").setup()
  require("ak.mini.visits") -- customized visits harpooned
end)

-- Not mentioned here, but can be useful:
-- - 'mini.doc' - needed only for plugin developers.
-- - 'mini.fuzzy' - not really needed on a daily basis.
-- - 'mini.test' - needed only for plugin developers.
