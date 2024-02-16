-- https://github.com/LazyVim/LazyVim/discussions/2559
-- c-/ works in alacritty, kitty and xterm, but not in tmux
-- c-_ works only in tmux
local open_mapping = vim.env.TMUX and [[<c-_>]] or [[<c-/>]]

-- 1 default horizontal
require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return vim.o.lines * 0.6
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.5
    end
  end,
  open_mapping = open_mapping,
  shading_factor = 2,
  direction = "horizontal",
  persist_size = false,
  persist_mode = true,
})

-- 2 vertical
vim.keymap.set("n", 2 .. open_mapping, function() require("toggleterm").toggle(2, 0, vim.loop.cwd(), "vertical") end, {
  desc = "Toggle Terminal Vertical",
  silent = true,
})

-- TODO: 3 REPL?

-- 4 lazygit in a new tab
local Terminal = require("toggleterm.terminal").Terminal
local lazygit = Terminal:new({ cmd = "lazygit", count = 3, hidden = true, direction = "tab" })
vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { noremap = true, silent = true })
