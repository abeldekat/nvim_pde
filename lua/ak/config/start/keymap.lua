-- https://www.reddit.com/r/neovim/comments/1kdrhjn/minikeymap_make_special_key_mappings_multistep/
-->
-- for example go to end of line by pressing ll rapidly within a configurable timer:
-- require('mini.keymap').map_combo({ 'n', 'x' }, 'll', '$')
-- require('mini.keymap').map_combo('i', 'll', '<BS><BS><End>')
-- require('mini.keymap').map_combo('c', 'll', '<BS><BS><C-e>')

-- Fix previous spelling mistake (see |[s| and |z=|) without manually leaving
-- insert mode:
-- local action = "<BS><BS><Esc>[s1z=gi<Right>"
-- require("mini.keymap").map_combo("i", "kk", action)

-- Hungry backspace?

require("mini.keymap").setup() -- use MiniKeymap elsewhere...
