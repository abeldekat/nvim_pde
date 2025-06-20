-- Feature request Improve 'mini.jump2d' default config and jumping experience #1818
--
-- Differences leap and jump2d:
-- Equivalence classes
-- Autojump to nearest on two chars. Requires "safe labels", which is inconvenient.
-- Match case-insensitive
-- Labels start from closest match, not top down
-- If many matches, still single chars closeby because of groups(press space).

local use_fork = true

-- akmini.jump2d_leaped is a copy from lua/mini/jump2d.lua,
-- in branch jump2d_two_characters,
-- in my fork https://github.com/abeldekat/mini.nivm
local source = use_fork and "akmini.jump2d_leaped" or "mini.jump2d"

require(source).setup({
  allowed_windows = { current = true, not_current = false },
  labels = "jklsdefmioh", -- 11 labels
  mappings = { start_jumping = "" },
  silent = true,
  view = { dim = true },
})

-- No repeat in operator pending mode... See mini.jump2d, H.apply_config.
local modes = { "n", "x", "o" }
local desc = "Start 2d jumping"
local start_single = function() return MiniJump2d.start(MiniJump2d.builtin_opts.single_character) end
local start_fork = function() return MiniJump2d.start_two_characters(MiniJump2d.builtin_opts.two_characters) end
local start = use_fork and start_fork or start_single
vim.keymap.set(modes, "s", start, { desc = desc })
