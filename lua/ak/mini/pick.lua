---@diagnostic disable: duplicate-set-field
-- - If query starts with `'`, the match is exact.
-- - If query starts with `^`, the match is exact at start.
-- - If query ends with `$`, the match is exact at end.
-- - If query starts with `*`, the match is forced to be fuzzy.
-- - Otherwise match is fuzzy.
-- - Sorting is done to first minimize match width and then match start.
--   Nothing more: no favoring certain places in string, etc.

local preview = function(buf_id, item) return MiniPick.default_preview(buf_id, item, { line_position = 'center' }) end
require('mini.pick').setup({ source = { preview = preview } })

vim.ui.select = function(items, opts, on_choice) -- use akextra.pick_hinted with vim.ui.select
  local start_opts = { hinted = { enable = true, use_autosubmit = true } }
  return MiniPick.ui_select(items, opts, on_choice, start_opts)
end

require('akextra.pick_hinted').setup({ -- 19 letters, no "bcgpqyz"
  hinted = {
    -- virt_clues_pos = { "inline", "eol" },
    chars = vim.split('adefhilmnorstu', ''),
  },
})

MiniPick.registry.grep_todo_keywords = function(local_opts)
  local_opts.pattern = '(TODO|FIXME|HACK|NOTE):'
  MiniPick.builtin.grep(local_opts, {})
end

local buffer_hints = vim.split('abcdefg', '')
MiniPick.registry.buffers_hinted = function() -- Perhaps: Add modified buffers visualization, issue 1810
  local hinted = { enable = true, use_autosubmit = true, chars = buffer_hints }
  MiniPick.builtin.buffers({ include_current = false }, { hinted = hinted })
end

MiniPick.registry.lsp_hinted = function(local_opts)
  MiniExtra.pickers.lsp(local_opts, { hinted = { enable = true, use_autosubmit = true } })
end

MiniPick.registry.oldfiles_hinted = function(local_opts)
  MiniExtra.pickers.oldfiles(local_opts, { hinted = { enable = true } })
end

MiniPick.registry.history_hinted = function(local_opts)
  MiniExtra.pickers.history(local_opts, { hinted = { enable = true } })
end
