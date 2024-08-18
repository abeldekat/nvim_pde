---@class ak.util.labels
local M = {}

M.visits = {
  "main", -- Main task context
  "side", -- Side task context
  "test", -- Testing context
  "col", -- Other files of interest, potentially more than four
}

M.grapple = { -- global, static, cwd, git, git_branch, lsp
  "git",
  "git_branch",
}

return M
