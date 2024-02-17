-- TODO: REPL?

local Terminal = require("toggleterm.terminal").Terminal

-- https://github.com/LazyVim/LazyVim/discussions/2559
-- c-/ works in alacritty, kitty and xterm, but not in tmux
-- c-_ works only in tmux
local open_mapping = vim.env.TMUX and [[<c-_>]] or [[<c-/>]]

-- 1 default horizontal in cwd
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

-- 2 vertical in cwd
vim.keymap.set("n", 2 .. open_mapping, function() require("toggleterm").toggle(2, 0, vim.loop.cwd(), "vertical") end, {
  desc = "Toggle Terminal Vertical",
  silent = true,
})

-- 3 horizontal in dir of file
-- This directory only changes after the terminal is exited!
local in_dir = Terminal:new({ count = 3 })
vim.keymap.set("n", 3 .. open_mapping, function()
  in_dir.dir = vim.fn.expand("%:p:h")
  in_dir:toggle()
end, { noremap = true, silent = true })

-- 4 tab, lazygit
-- hidden = true, does not toggle, press q for lazygit
local lazygit = Terminal:new({ cmd = "lazygit", count = 4, hidden = true, direction = "tab" })
vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { noremap = true, silent = true })
