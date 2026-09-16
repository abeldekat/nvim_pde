---@diagnostic disable: undefined-global
local jump2d = require('mini.jump2d')
jump2d.setup({
  spotter = jump2d.gen_spotter.pattern('[^%s%p]+'),
  -- hand restriction, remove afg, add eui
  labels = 'sdehjkl;ui',
  mappings = { start_jumping = '' },
  view = { dim = true, n_steps_ahead = 2 },
})

vim.keymap.set({ 'n', 'x', 'o' }, 'sj', function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end)
vim.keymap.set({ 'n', 'x', 'o' }, 'sk', function() MiniJump2d.start(MiniJump2d.builtin_opts.word_start) end)
vim.keymap.set({ 'n', 'x', 'o' }, 'sl', function() MiniJump2d.start(MiniJump2d.builtin_opts.line_start) end)
