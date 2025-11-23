local lint = require('lint')

lint.linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  sh = { 'shellcheck' },
}

-- { "BufWritePost", "BufReadPost", "InsertLeave" }, or perhaps: Filetype
_G.Config.new_autocmd({ 'BufWritePost' }, nil, function()
  if _G.Config.disable_autolint then return end

  lint.try_lint() -- nil, { ignore_errors = true })
end, 'Auto-lint')

_G.Config.toggle_lint = function()
  _G.Config.disable_autolint = not _G.Config.disable_autolint
  vim.notify('Auto-lint ' .. (_G.Config.disable_autolint and 'off' or 'on'))
end
