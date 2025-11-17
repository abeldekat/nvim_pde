local now, later = MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

now(function()
  -- vim.cmd("colorscheme miniwinter") -- see 29_color.lua
  require("ak.mini.basics")
  require("ak.mini.icons")
end)

now_if_args(function()
  require("ak.mini.misc") --
end)

now(function()
  require("ak.mini.notify")
  require("mini.sessions").setup()

  if vim.fn.argc(-1) == 0 then require("ak.mini.starter") end
  vim.o.statusline = " " -- wait till statusline plugin is loaded
  -- require("mini.tabline").setup()
end)

later(function()
  require("ak.mini.statusline") -- MiniMax activates statusline  on `now` 
  require("mini.extra").setup()
  require("ak.mini.ai")
  require("mini.align").setup()
  -- require("mini.animate").setup()
  require("mini.bracketed").setup()
  require("mini.bufremove").setup()
  require("ak.mini.clue")
  -- require("mini.comment").setup()
  require("ak.mini.completion")
  -- require("mini.cursorword").setup()
  require("mini.diff").setup()
  require("ak.mini.files")
  require("mini.git").setup()
  require("ak.mini.hipatterns")
  require("mini.indentscope").setup()
  require("mini.jump").setup()
  require("ak.mini.jump2d")
  require("ak.mini.keymap")
  require("ak.mini.map")
  require("mini.move").setup()
  require("mini.operators").setup() -- Skipped mappings to swap arg
  require("mini.pick").setup()
  require("ak.mini.snippets")
  require("mini.splitjoin").setup()
  require("mini.surround").setup() -- `sa sd sr sf sF sh sn`
  require("mini.trailspace").setup()
  require("ak.mini.visits") -- customized visits harpooned
end)

-- Not mentioned here, but can be useful:
-- - 'mini.colors' - not really needed on a daily basis.
-- - 'mini.doc' - needed only for plugin developers.
-- - 'mini.fuzzy' - not really needed on a daily basis.
-- - 'mini.test' - needed only for plugin developers.
