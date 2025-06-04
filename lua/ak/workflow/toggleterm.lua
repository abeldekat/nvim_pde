local Lazygit = require("akshared.color_lazygit")

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

local function lazygit_toggle(term)
  return function()
    Lazygit.update_if_needed()
    term:toggle()
  end
end

local terminal = require("toggleterm.terminal")
local Terminal = terminal.Terminal

vim.keymap.set("n", "<leader>gf", function() -- press q
  local git_path = vim.api.nvim_buf_get_name(0)
  lazygit_toggle(Terminal:new({
    cmd = "lazygit -f " .. vim.trim(git_path),
    count = 98,
    hidden = true,
    direction = "float",
  }))()
end, { desc = "Lazygit file", silent = true })

-- press q:
local lazygit = Terminal:new({ cmd = "lazygit", count = 99, hidden = true, direction = "tab" })
vim.keymap.set("n", "<leader>gg", lazygit_toggle(lazygit), { desc = "Lazygit", silent = true })

vim.keymap.set("n", "<leader>ot", function() vim.cmd("ToggleTermToggleAll") end, {
  desc = "ToggleTerm all",
  silent = true,
})

-- see :h filename-modifiers
-- in normal mode, in a toggle term, cd to dir of alternate file
-- toggle first to update the alternate file...
vim.keymap.set("n", "<leader>oC", function()
  local id = terminal.get_focused_id()
  local target = terminal.get(id)
  local alternate_dir = vim.fn.expand("#:~:h")
  if target and alternate_dir then target:send("cd " .. alternate_dir) end
end, {
  desc = "ToggleTerm #cd",
  silent = true,
})
