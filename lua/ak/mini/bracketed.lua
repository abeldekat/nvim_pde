---@diagnostic disable: undefined-global

-- Do not overwrite builtin [C and C], used by multicursor(nvim-0.13+)
-- I never navigate to first or last comment...
-- Use gg and forward, or G and backward
require('mini.bracketed').setup({
  comment = { suffix = '' },
})

local map = vim.keymap.set
local modes = { 'n', 'x', 'o' }
map(modes, '[c', "<Cmd>lua MiniBracketed.comment('backward')<CR>", { silent = true, desc = 'Comment backward' })
map(modes, ']c', "<Cmd>lua MiniBracketed.comment('forward')<CR>", { silent = true, desc = 'Comment forward' })
