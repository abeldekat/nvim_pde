-- Cannot use gs and gS because of mini.operators...

-- Jump2d discussion:
-- https://github.com/echasnovski/mini.nvim/discussions/1033#discussioncomment-10289232

-- Important:
-- Autojumping: see leap.opts.safe_labels and leap.opts.labels
-- Using bidirectional `s` for Normal and Visual mode as mentioned in help
-- Not using directional search, so enter cannot traverse to the rest of the targets
-- Not using require("leap.user").set_repeat_keys. s and enter to go next is good enough
-- Also, one can always do / and n

-- From the help:
-- ...
-- • Else: type the label character, that is now active. If there are more
--   matches than available labels, you can switch between groups, using
--   `<space>` and `<backspace>`.
-- ...
-- A character at the end of a line can be targeted by pressing `<space>` after
-- it. There is no special mechanism behind this: `<space>` is simply an alias
-- for `\n` and `\r`, set in |leap.opts.equivalence_classes| by default.
-- ...
-- A slightly more magical feature is that you can target actual EOL positions,
-- including empty lines, by pressing the newline alias twice (`<space><space>`).
-- This fulfills the principle that any visible position you can move to with the
-- cursor should be reachable by Leap too.
-- ...
-- At any stage (after 0, 1, or 2 input characters), `<enter>`
-- (|leap.opts.special_keys.next_target|) consistently jumps to the first
-- available target. Pressing it right after invocation (`s<enter>`) repeats the
-- previous search. Pressing it after one input character (`s{char}<enter>`) can
-- be used as a multiline substitute for `fFtT` motions.
-- ...
-- End from the help

require("leap").opts.equivalence_classes = { " \t\r\n", "([{", ")]}", "'\"`" }

local nx = { "n", "x" }
local function current_window()
  require("leap").leap({
    target_windows = { vim.api.nvim_get_current_win() },
  })
end
local function other_windows()
  require("leap").leap({
    target_windows = require("leap.util").get_enterable_windows(),
  })
end

vim.keymap.set(nx, "s", current_window, { desc = "Leap" })
-- Don't combine current with other. Autojump has a higher change to kick in:
vim.keymap.set(nx, "S", other_windows, { desc = "Leap from window" })

local o = "o"
local function operator_forward() require("leap").leap() end
local function operator_backward() require("leap").leap({ backward = true }) end
local function remote_action() require("leap.remote").action() end

-- In operator mode, bidirectional search is not recommended:
vim.keymap.set(o, "s", operator_forward, { desc = "Leap" })
vim.keymap.set(o, "S", operator_backward, { desc = "Leap backward" })
-- Restrict remote operations to operating pending mode:
vim.keymap.set(o, "r", remote_action, { desc = "Leap remote" })

local nox = { "n", "o", "x" }
local function leap_treesitter() require("leap.treesitter").select() end

-- Leap and treesitter incremental selection. <C-Space> is in used by tmux:
vim.keymap.set(nox, "gb", leap_treesitter, { desc = "Leap treesitter" })
