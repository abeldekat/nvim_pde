return { --To map /: use <C-_> instead of <C-/>.
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = {
    "TermExec",
    "ToggleTerm",
    "ToggleTermToggleAll",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
  },
  keys = { { [[<c-_>]], "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal" } },
  config = function()
    require("toggleterm").setup({
      size = 15,
      open_mapping = [[<c-_>]],
      insert_mappings = false,
      terminal_mappings = false,
      shading_factor = 2,
      direction = "horizontal",
    })
  end,
}
