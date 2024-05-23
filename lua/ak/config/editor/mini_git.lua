--          ╭─────────────────────────────────────────────────────────╮
--          │                 WIP: Replacing gitsigns                 │
--          ╰─────────────────────────────────────────────────────────╯

local augroup = vim.api.nvim_create_augroup("MiniGitAk", {})
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MiniGitUpdated",
  callback = function(data)
    local summary = vim.b[data.buf].minigit_summary_string
    if not summary then return end

    summary = string.gsub(summary, " ", "", 1) -- remove space between name and status
    summary = string.gsub(summary, "%(", "[")
    summary = string.gsub(summary, "%)", "]")
    vim.b[data.buf].minigit_summary_string = summary
  end,
  desc = "Diff in statusline",
})

require("mini.git").setup({})
