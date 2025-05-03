require("mini.keymap").setup()

-- Fix previous spelling mistake (see |[s| and |z=|) without manually leaving
-- Insert mode:
-- local action = "<BS><BS><Esc>[s1z=gi<Right>"
-- require("mini.keymap").map_combo("i", "kk", action)

-- Use double <Esc><Esc> to execute |:nohlsearch|.
