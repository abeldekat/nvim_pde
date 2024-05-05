local Util = require("ak.util")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then opts.remap = nil end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- quit, write
-- added:
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Write" })

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Resize window using <ctrl> arrow keys
-- map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
-- map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
-- map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
-- map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Window resize (respecting `v:count`) -> mini.basics
-- stylua: ignore start
map('n', '<C-Left>',  '"<Cmd>vertical resize -" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window width' })
map('n', '<C-Down>',  '"<Cmd>resize -"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Decrease window height' })
map('n', '<C-Up>',    '"<Cmd>resize +"          . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window height' })
map('n', '<C-Right>', '"<Cmd>vertical resize +" . v:count1 . "<CR>"', { expr = true, replace_keycodes = false, desc = 'Increase window width' })
-- stylua: ignore end

-- Move Lines
-- see mini.move
-- map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
-- map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
-- map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
-- map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
-- map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
-- map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to alternate" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = severity }) end
end
-- kickstart:
-- map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })

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

if vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint then
  map("n", "<leader>uh", function() Util.toggle.inlay_hints() end, { desc = "Toggle inlay hints" })
end

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

-- terminal mappings: esc is slow when using vi-mode in the terminal
-- added:
map("t", "<c-j>", "<c-\\><c-n>", { desc = "Enter normal mode" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
-- added:
map("n", "<leader>1", "1gt", { desc = "Tab 1" })
map("n", "<leader>2", "2gt", { desc = "Tab 2" })
map("n", "<leader>3", "3gt", { desc = "Tab 3" })
map("n", "<leader><tab>s", "<cmd>tabs<cr>", { desc = "Show tabs" })

--          ╭─────────────────────────────────────────────────────────╮
--          │                          ADDED                          │
--          ╰─────────────────────────────────────────────────────────╯

-- Window navigation combining right and left hand
map("n", "me", "<C-W>p", { desc = "Last accessed window", remap = true })
map("n", "mw", "<C-W>w", { desc = "Next window", remap = true })
--
-- The disadvantage of combining with zz: Less number of lines per movement
-- map("n", "<C-d>", "<C-d>zz", { desc = "Better ctrl-d" })
-- map("n", "<C-u>", "<C-u>zz", { desc = "Better ctrl-u" })

-- Down half page combining left and right hand:
-- c-n can behave like j and enter, also sometimes "next":
map("n", "<C-N>", "<C-d>", { desc = "Down half page, better ctrl-d" })

-- https://www.reddit.com/r/neovim/comments/mbj8m5/how_to_setup_ctrlshiftkey_mappings_in_neovim_and/
-- TODO: Modify alacritty.yml. See harpoon setup
-- vim.keymap.set("n", "<C-S-P>", function()
-- end)
-- vim.keymap.set("n", "<C-S-N>", function()
-- end)
