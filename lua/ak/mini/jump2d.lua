-- Testing the approach from echasnovski's config
local jump2d = require("mini.jump2d")
jump2d.setup({
  spotter = jump2d.gen_spotter.pattern("[^%s%p]+"),
  labels = "asdfghlnmio",
  view = { dim = true, n_steps_ahead = 2 },
})
vim.keymap.set({ "n", "x", "o" }, "sj", function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end)
-- colemak dh:
vim.keymap.set({ "n", "x", "o" }, "se", function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end)
