-- asdf cannot be used for marks. Easy to remember, adjacent on keyboard.
require("mini.surround").setup({
  mappings = {
    add = "ma",
    delete = "md",
    find = "mf", -- Find surrounding (to the right)
    find_left = "mF", -- Find surrounding (to the left)
    highlight = "mH", -- Highlight surrounding
    replace = "ms", -- Substitute surrounding(aka change, replace)
  },
})

-- Not needed:
--   vim.keymap.set('n', 'sn', '<Cmd>lua MiniSurround.update_n_lines()<CR>')
