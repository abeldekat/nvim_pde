-- - Configurable mappings to manage diff hunks:
--     - Apply and reset hunks inside region (selected visually or with
--       a dot-repeatable operator).
--     - "Hunk range under cursor" textobject to be used as operator target.
--     - Navigate to first/previous/next/last hunk. See |MiniDiff.goto_hunk()|.

-- What it doesn't do:
--
-- - Provide functionality to work directly with Git outside of visualizing
--   and staging (applying) hunks with (default) Git source. In particular,
--   unstaging hunks is not supported. See |MiniDiff.gen_source.git()|.

-- This module provides mappings for common actions with diffs, like:
-- - Apply and reset hunks.
-- - "Hunk range under cursor" textobject.
-- - Go to first/previous/next/last hunk range.

-- Examples:
-- - `vip` followed by `gh` / `gH` applies/resets hunks inside current paragraph.
--   Same can be achieved in operator form `ghip` / `gHip`, which has the
--   advantage of being dot-repeatable (see |single-repeat|).
-- - `gh_` / `gH_` applies/resets current line (even if it is not a full hunk).
-- - `ghgh` / `gHgh` applies/resets hunk range under cursor.
-- - `dgh` deletes hunk range under cursor.
-- - `[H` / `[h` / `]h` / `]H` navigate cursor to the first / previous / next / last
--   hunk range of the current buffer.

local augroup = vim.api.nvim_create_augroup("MiniDiffAk", {})
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MiniDiffUpdated",
  callback = function(data)
    local summary = vim.b[data.buf].minidiff_summary_string
    if not summary then return end

    vim.b[data.buf].minidiff_summary_string = summary:gsub(" ", "")
  end,
  desc = "Diff in statusline",
})

local map = vim.keymap.set
local yank_hunk = function() return MiniDiff.operator("yank") .. "gh" end
map("n", "ghy", yank_hunk, { expr = true, remap = true, desc = "Copy hunk's reference lines" })
local toggle_overlay = function() require("mini.diff").toggle_overlay(0) end
map("n", "<leader>go", toggle_overlay, { desc = "Toggle mini.diff overlay", silent = true })

map("n", "gq", function() -- Overrides format the lines that {motion} moves over.
  vim.fn.setqflist(MiniDiff.export("qf"))
  vim.cmd("copen")
end, { desc = "Quickfix diffs" })

-- view = { style = "sign", signs = { add = "▎", change = "▎", delete = "" } },
require("mini.diff").setup({ wrap_goto = true })
