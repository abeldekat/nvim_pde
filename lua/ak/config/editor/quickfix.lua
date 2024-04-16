--          ╭─────────────────────────────────────────────────────────╮
--          │                  Replaces trouble.nvim                  │
--          ╰─────────────────────────────────────────────────────────╯
-- Press <Tab> or <S-Tab> to toggle the sign of item
-- Press zn or zN will create new quickfix list
-- Press zf in quickfix window will enter fzf mode --> use Telescope quickfix.

require("pqf").setup({
  show_multiple_lines = true,
  max_filename_length = 40,
})
require("bqf").setup({
  func_map = { split = "<C-s>" },
})
