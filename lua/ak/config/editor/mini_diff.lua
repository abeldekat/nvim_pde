--          ╭─────────────────────────────────────────────────────────╮
--          │                 WIP: Replacing gitsigns                 │
--          ╰─────────────────────────────────────────────────────────╯

local opts = {
  view = {
    style = "sign",
    signs = {
      add = "▎",
      change = "▎",
      delete = "",
    },
  },
}
require("mini.diff").setup(opts)

vim.keymap.set(
  "n",
  "<leader>go",
  function() require("mini.diff").toggle_overlay(0) end,
  { desc = "Toggle mini.diff overlay", silent = true }
)
