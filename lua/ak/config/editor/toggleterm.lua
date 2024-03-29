-- CAVEATS - Having multiple terminals with different directions open at the same time is unsupported.

-- c-/ works in alacritty, kitty and xterm, but not in tmux
-- c-_ works only in tmux,
local open_mapping = vim.env.TMUX and [[<c-_>]] or [[<c-/>]]
local direction = "horizontal"

require("toggleterm").setup({
  size = function(term)
    if term.direction == "horizontal" then
      return vim.o.lines * 0.6
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.5
    end
  end,
  open_mapping = open_mapping,
  -- start_in_insert = false,
  shading_factor = 2,
  direction = direction,
  persist_size = false, -- temporarily change window position must be possible
  persist_mode = true,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Keymaps                         │
--          ╰─────────────────────────────────────────────────────────╯

-- tab, lazygit, full-screen
-- hidden = true, does not toggle, press q for lazygit
local lazygit =
  require("toggleterm.terminal").Terminal:new({ cmd = "lazygit", count = 99, hidden = true, direction = "tab" })
vim.keymap.set("n", "<leader>gg", function() lazygit:toggle() end, { desc = "Lazygit", noremap = true, silent = true })

vim.keymap.set("n", "<leader>mt", function() vim.cmd("ToggleTermToggleAll") end, {
  desc = "ToggleTerm all",
  silent = true,
})

-- TEST:
-- see :h filename-modifiers
-- in normal mode, in a toggle term, cd to dir of alternate file
-- toggle first to update the alternate file...
vim.keymap.set("n", "<leader>mc", function()
  local terminal = require("toggleterm.terminal")
  local id = terminal.get_focused_id()
  local target = terminal.get(id)
  local alternate_dir = vim.fn.expand("#:~:h")
  if target and alternate_dir then target:send("cd " .. alternate_dir) end
end, {
  desc = "ToggleTerm #cd",
  silent = true,
})
