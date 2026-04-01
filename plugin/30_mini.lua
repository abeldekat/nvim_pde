local now, later, now_if_args = Config.now, Config.later, Config.now_if_args

-- now(function() vim.cmd('colorscheme miniwinter') end) -- see 29_color.lua
now(function() require('ak.mini.basics') end)
now(function()
  require('ak.mini.icons')
  later(MiniIcons.tweak_lsp_kind)
end)
now(function() require('ak.mini.notify') end)
now(function() require('mini.sessions').setup() end)
now(function() -- MiniMax always loads starter
  if vim.fn.argc(-1) == 0 then require('ak.mini.starter') end
  vim.o.statusline = ' ' -- added: wait till statusline plugin is loaded
end)
later(function() -- MiniMax activates statusline  on `now`
  require('ak.mini.statusline')
end)
-- now(function() require('mini.tabline').setup() end)

now_if_args(function() require('ak.mini.completion') end)
now_if_args(function() require('ak.mini.files') end)
now_if_args(function() require('ak.mini.misc') end)

later(function() require('mini.extra').setup() end)
later(function() require('ak.mini.ai') end)
later(function() require('mini.align').setup() end)
-- later(function() require('mini.animate').setup() end)
later(function() require('mini.bracketed').setup() end)
later(function() require('mini.bufremove').setup() end)
later(function() require('ak.mini.clue') end)
later(function() require('mini.cmdline').setup() end)
-- later(function() require('mini.comment').setup() end)
later(function() require('mini.cursorword').setup() end)
later(function() require('mini.diff').setup() end)
later(function() require('mini.git').setup() end)
later(function() require('ak.mini.hipatterns') end)
later(function() require('mini.indentscope').setup() end)
later(function() require('mini.jump').setup() end)
later(function() require('ak.mini.jump2d') end)
later(function() require('ak.mini.keymap') end)
later(function() require('ak.mini.map') end)
later(function() require('mini.move').setup() end)
later(function() require('mini.operators').setup() end) -- skipped swap arg mappings
later(function() require('ak.mini.pairs') end)
later(function() require('ak.mini.pick') end)
later(function() require('ak.mini.snippets') end)
later(function() require('mini.splitjoin').setup() end)
later(function() require('mini.surround').setup() end) -- `sa sd sr sh sF sf`, last, next
later(function() require('mini.trailspace').setup() end)
later(function() require('ak.mini.visits') end)

-- Not mentioned here, but can be useful:
-- - 'mini.colors' - not really needed on a daily basis.
-- - 'mini.doc' - needed only for plugin developers.
-- - 'mini.fuzzy' - not really needed on a daily basis.
-- - 'mini.test' - needed only for plugin developers.
