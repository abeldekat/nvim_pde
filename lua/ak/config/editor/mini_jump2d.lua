-- Intent in normal mode using word_start:
-- - focus on target position and start_jumping
-- - all word starts are visible showing all lowercase labels at once
-- - insert the two labels
-- - reached destination
-- - fine-tune location if needed using f/F/t/T/w/b/e
--
-- Notes:
-- One short mental pause(label distribution is somewhat predictable) after "start jumping".
-- Labels must be lowercase. Uppercase labels disturb the flow.
--
-- Intent in visual and operator pending mode using single_character:
-- All characters must be reachable. Speed is less important.
--
-- Other spotters:
-- 1. default: Too crowded. It is harder to correctly focus on the target
-- 2. single_character with n_steps_ahead = 2:
-- The first character needs to be typed as is(some chars are more difficult)

local Jump2d = require("mini.jump2d")
local key = "<CR>" -- "s"

local function map(mode, rhs, opts) -- adapted from mini.jump2d
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, key, rhs, opts)
end
local function create_autocmds()
  local augroup = vim.api.nvim_create_augroup("MiniJump2dCustom", {})
  local au = function(e, p, c, desc)
    vim.api.nvim_create_autocmd(e, { pattern = p, group = augroup, callback = c, desc = desc })
  end
  local revert_cr = function() vim.keymap.set("n", key, key, { buffer = true }) end

  au("FileType", "qf", revert_cr, "Revert " .. key)
  au("CmdwinEnter", "*", revert_cr, "Revert " .. key)
end

create_autocmds()
map("n", function()
  local builtin = Jump2d.builtin_opts.word_start
  builtin.view = { n_steps_ahead = 10, dim = true }
  Jump2d.start(builtin)
end, { desc = "Start 2d jumping" })
map({ "x", "o" }, function()
  local builtin = Jump2d.builtin_opts.default -- single_character
  builtin.view = { dim = true }
  Jump2d.start(builtin)
end, { desc = "Start 2d jumping" })
Jump2d.setup({
  labels = "cdefghijklmnoprstuvwxy", -- improve typing: removed b and qaz
  mappings = { start_jumping = "" }, -- no mappings, using 2 different builtins
})
