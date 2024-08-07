-- Note: Used for exchange:
-- gx in Normal mode calls vim.ui.open() on whatever is under the cursor,
-- which shells out to your operating system’s “open” capability

local Util = require("ak.util")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then opts.remap = nil end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Buffer '#'" })

-- clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })
-- clear search, diff update and redraw, taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- command history navigation (dotfiles echasnovski):
map("c", "<C-p>", "<Up>", { silent = false })
map("c", "<C-n>", "<Down>", { silent = false })

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- diagnostic
-- <C-W>d (and <C-W><C-D>) in Normal mode map to vim.diagnostic.open_float().
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = severity }) end
end
-- kickstart:
-- map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
-- map("n", "]d", diagnostic_goto(true), { desc = "Next diagnostic" })
-- map("n", "[d", diagnostic_goto(false), { desc = "Prev diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })

-- edit cwd
-- using grapple, tmux-sessionizer and tmuxp, other explore mappings are not needed
map("n", "<leader>e", function() vim.cmd.edit(vim.uv.cwd()) end, { desc = "Edit cwd" })

-- indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- move Lines: see mini.move
-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- n behavior https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- quickfix
map("n", "<leader>x", Util.toggle.quickfix, { desc = "Quickfix toggle" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- quit, write
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Write" })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader>1", "1gt", { desc = "Tab 1" })
map("n", "<leader>2", "2gt", { desc = "Tab 2" })
map("n", "<leader>3", "3gt", { desc = "Tab 3" })
map("n", "<leader><tab>s", "<cmd>tabs<cr>", { desc = "Show tabs" })

-- terminal mappings: esc is slow when using vi-mode in the terminal
map("t", "<c-j>", "<c-\\><c-n>", { desc = "Enter normal mode" })

-- toggle options
map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle spelling" })
map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle word wrap" })
map("n", "<leader>uL", function() Util.toggle("relativenumber") end, { desc = "Toggle relative line numbers" })
map("n", "<leader>ul", function() Util.toggle.number() end, { desc = "Toggle line numbers" })
map("n", "<leader>ud", function() Util.toggle.diagnostic() end, { desc = "Toggle diagnostic" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map(
  "n",
  "<leader>uc",
  function() Util.toggle("conceallevel", false, { 0, conceallevel }) end,
  { desc = "Toggle conceal" }
)
map("n", "<leader>uh", function() Util.toggle.inlay_hints() end, { desc = "Toggle inlay hints" })
map("n", "<leader>uT", function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end --
end, { desc = "Toggle treesitter highlight" })
-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
-- down half page combining left and right hand:
-- c-n can behave like j and enter, also sometimes "next":
map("n", "<C-N>", "<C-d>", { desc = "Down half page" })

-- window
map("n", "<leader>-", "<C-W>s", { desc = "Win split below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Win split right", remap = true })
-- window navigation combining right and left hand
map("n", "me", "<C-W>p", { desc = "Last accessed win", remap = true })
map("n", "mw", "<C-W>w", { desc = "Next win", remap = true })

-- window resize (respecting `v:count`) -> mini.basics
-- stylua: ignore start
map('n', '<C-Left>', '"<Cmd>vertical resize -" . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
map('n', '<C-Down>', '"<Cmd>resize -"          . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
map('n', '<C-Up>', '"<Cmd>resize +"          . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window height' })
map('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"',
  { expr = true, replace_keycodes = false, desc = 'Increase window width' })
-- stylua: ignore end
