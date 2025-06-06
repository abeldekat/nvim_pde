local augroup = vim.api.nvim_create_augroup("MiniGitAk", {})
vim.api.nvim_create_autocmd("User", {
  group = augroup,
  pattern = "MiniGitUpdated",
  callback = function(data)
    local summary = vim.b[data.buf].minigit_summary_string
    if not summary then return end

    summary = summary:gsub(" ", "", 1) -- remove space between name and status
    vim.b[data.buf].minigit_summary_string = summary
  end,
  desc = "Diff in statusline",
})

local map = function(mode, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set(mode, lhs, rhs, opts)
end
map("n", "<leader>gc", "<Cmd>Git commit<CR>", "Commit")
map("n", "<leader>gC", "<Cmd>Git commit --amend<CR>", "Commit amend")
-- <leader>gf: toggleterm lazygit
-- <leader>gg: toggleterm lazygit
map("n", "<leader>gl", "<Cmd>Git log --oneline<CR>", "Log")
map("n", "<leader>gL", "<Cmd>Git log --oneline --follow -- %<CR>", "Log buffer")
-- <leader>go: mini.diff
map("n", "<leader>gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at cursor")
map("x", "<leader>gs", "<Cmd>lua MiniGit.show_at_cursor()<CR>", "Show at selection")

require("mini.git").setup()
