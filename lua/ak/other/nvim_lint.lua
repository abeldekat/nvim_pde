local lint = require('lint')

lint.linters_by_ft = {
  markdown = { 'markdownlint-cli2' },
  sh = { 'shellcheck' },
}

-- { "BufWritePost", "BufReadPost", "InsertLeave" }
Config.new_autocmd({ 'Filetype', 'BufWritePost' }, nil, function()
  if Config.disable_autolint then return end

  lint.try_lint() -- nil, { ignore_errors = true })
end, 'Auto-lint')

Config.toggle_lint = function()
  Config.disable_autolint = not Config.disable_autolint
  vim.notify('Auto-lint ' .. (Config.disable_autolint and 'off' or 'on'))
end
