-- Preqequisite: Uppercase labels disturbe the flow!
-- Intent in normal mode using word_start:
-- - focus on target position
-- - press "start_jumping"
-- - all word starts are visible showing all lowercase labels at once
-- - insert the two labels
-- - reached destination.
-- - finetune location if needed using f/F/t/T
--
-- One short mental pause(label distribution is somewhat predicatable) after "start jumping".
--
-- Other spotters:
-- 1. default: Too crowded. It is harder to correctly focus on the target
-- 2. single_character with n_steps_ahead = 2:
-- The first character needs to be typed as is(some chars are more difficult)
--
-- Intent in visual and operator pending mode using single_character:
-- All characters must be reachable. Speed is less important. No need for n_steps_ahead

-- TESTING: replace leap with mini.jump2d

-- TODO: jump2d-remote?
local Jump2d = require("mini.jump2d")

local function map(mode, rhs, opts) -- adapted from mini.jump2d
  local lhs = "<CR>" -- "s"
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end
local function start_in_normal_mode()
  local builtin = Jump2d.builtin_opts.word_start
  builtin.view = { n_steps_ahead = 10 }
  Jump2d.start(builtin)
end
local function start()
  local builtin = Jump2d.builtin_opts.single_character
  Jump2d.start(builtin)
end

Jump2d.setup({ -- labels: all lowercase
  mappings = { start_jumping = "" }, -- do not create mappings
  view = { dim = true },
})
map("n", start_in_normal_mode, { desc = "Start 2d jumping" })
map({ "x", "o" }, start, { desc = "Start 2d jumping" })
