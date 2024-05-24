--          ╭─────────────────────────────────────────────────────────╮
--          │                 WIP: Replacing gitsigns                 │
--          ╰─────────────────────────────────────────────────────────╯

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
