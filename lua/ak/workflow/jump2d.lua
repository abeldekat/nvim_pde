-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
--
-- Differences leap and jump2d:
-- Autojump to nearest on two chars. Requires "safe labels". Not needed.
-- Match case-insensitive
-- Labels start from closest match, not top down
-- If many matches, still single chars closeby because of groups(press space).

require("mini.jump2d").setup({
  -- allowed_lines = { cursor_at = false }, -- try to minimize matches by using fFtT on current line.
  labels = "jkl;mhniosde",
  mappings = { start_jumping = "" },
  silent = true,
  view = { dim = true, n_steps_ahead = 100 },
})

-- No repeat in operator pending mode... See mini.jump2d H.apply_config.
local modes = { "n", "x", "o" }
local desc = "Start 2d jumping"
vim.keymap.set(modes, "s", function() MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end, { desc = desc })
