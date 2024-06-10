--          ╭─────────────────────────────────────────────────────────╮
--          │                 WIP: Replacing gitsigns                 │
--          ╰─────────────────────────────────────────────────────────╯

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

vim.keymap.set(
  "n",
  "<leader>go",
  function() require("mini.diff").toggle_overlay(0) end,
  { desc = "Toggle mini.diff overlay", silent = true }
)

require("mini.diff").setup({
  view = {
    style = "sign",
    signs = {
      add = "▎",
      change = "▎",
      delete = "",
    },
  },
})
