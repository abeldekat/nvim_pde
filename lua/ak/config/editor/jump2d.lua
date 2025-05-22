-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818

local jump2d = require("mini.jump2d")
jump2d.setup({
  allowed_lines = {
    blank = false, -- type j/k after the jump, or use paragraph motions...
    current = false, -- use fFtT on current line. Does not work on word_start?
  },
  allowed_windows = { -- I don't work with split windows that much
    not_current = false,
  },
  labels = "hjkl;'asdf", -- homerow, added ', removed the g, left hand restriction
  mappings = { start_jumping = "s" },
  spotter = jump2d.builtin_opts.word_start.spotter,
  view = {
    dim = true,
    n_steps_ahead = 2,
  },
})
