local Util = require("ak.util")

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then opts.remap = nil end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Buffers alternate. The back-quote is easier to type:
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Buffer '#'" })

-- Clear search with <esc>:
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Command history navigation (nvim echasnovski):
map("c", "<C-p>", "<Up>", { silent = false })
map("c", "<C-n>", "<Down>", { silent = false })

-- Commenting above or below:
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- Edit cwd:
-- See mini.files, the cwd bookmark
-- Not needed when using mini.files, mini.visits, tmux-sessionizer and tmuxp
-- map("n", "<leader>e", function() vim.cmd.edit(vim.uv.cwd()) end, { desc = "Edit cwd" })

-- Indenting:
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Keywordprg:
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- Move Lines: see mini.move

-- N behavior: https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n:
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Quickfix:
map("n", "<leader>x", Util.toggle.quickfix, { desc = "Quickfix toggle" })

-- Quit and write:
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Write" })

-- Tabs:
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>s", "<cmd>tabs<cr>", { desc = "Show tabs" })
map("n", "<leader>1", "1gt", { desc = "Tab 1" })
map("n", "<leader>2", "2gt", { desc = "Tab 2" })
map("n", "<leader>3", "3gt", { desc = "Tab 3" })

-- Terminal mappings: esc is slow when using vi-mode in the terminal:
map("t", "<c-j>", "<c-\\><c-n>", { desc = "Enter normal mode" })

-- Toggle options:
-- Not used but possible: mini.basics, option_toggle_prefix...
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
local toggle_conceal = function() Util.toggle("conceallevel", false, { 0, conceallevel }) end
local toggle_foldlevel = function()
  if vim.o.foldlevel == 1 then
    vim.o.foldlevel = 99
  else
    vim.o.foldlevel = 1
  end
end
local toggle_ts_hl = function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end --
end
local ur = -- clear search, diff update and redraw, taken from runtime/lua/_editor.lua:
  { cmd = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", desc = "Redraw / clear hlsearch / diff update" }
map("n", "<leader>uc", toggle_conceal, { desc = "Toggle conceal" })
map("n", "<leader>ud", function() Util.toggle.diagnostic() end, { desc = "Toggle diagnostic" })
map("n", "<leader>uh", function() Util.toggle.inlay_hints() end, { desc = "Toggle inlay hints" })
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })
map("n", "<leader>ul", function() Util.toggle.number() end, { desc = "Toggle line numbers" })
map("n", "<leader>uL", function() Util.toggle("relativenumber") end, { desc = "Toggle relative line numbers" })
map("n", "<leader>uo", toggle_foldlevel, { desc = "Toggle foldlevel" })
map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle spelling" })
map("n", "<leader>ur", ur.cmd, { desc = ur.desc })
map("n", "<leader>uT", toggle_ts_hl, { desc = "Toggle treesitter highlight" })
map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle word wrap" })

-- Up/down:
-- Down half page combining left and right hand:
-- c-n can behave like j and enter, also sometimes "next":
map("n", "<C-N>", "<C-d>", { desc = "Down half page" })

-- Window:
map("n", "<leader>-", "<C-W>s", { desc = "Win split below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Win split right", remap = true })

-- Window navigation combining right and left hand:
map("n", "me", "<C-W>p", { desc = "Last accessed win", remap = true })
map("n", "mw", "<C-W>w", { desc = "Next win", remap = true })
