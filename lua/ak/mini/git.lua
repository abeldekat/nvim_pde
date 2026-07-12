---@diagnostic disable: undefined-global

--[[
General idea of folding levels (use |zr| and |zm| to adjust interactively):
- At level 0 there is one line per whole patch or log entry.
- At level 1 there is one line per patched file.
- At level 2 there is one line per hunk.
- At level 3 there is no folds.
--]]
require('mini.git').setup()

-- `:h MiniGit-examples`
-- :vertical Git blame -- %
local align_blame = function(au_data)
  MiniMisc.log_add('blame', { au_data = au_data })
  if au_data.data.git_subcommand ~= 'blame' then return end

  -- Align blame output with source
  local win_src = au_data.data.win_source
  vim.wo.wrap = false
  vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
  vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })

  -- Bind both windows so that they scroll together
  vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
end
Config.new_autocmd('User', 'MiniGitCommandSplit', align_blame, 'Align blame')
