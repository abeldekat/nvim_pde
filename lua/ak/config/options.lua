vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local o = vim.o -- all "o" are taken from nvim echasnovski

local opt = vim.opt
vim.schedule(function() -- includes system call responsible for 40% startuptime!
  opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus" -- Sync with system clipboard
end)

opt.breakindent = true
o.breakindentopt = "list:-1" -- Add padding for lists when 'wrap' is on

o.complete = ".,b,kspell" -- Use spell check and don't use tags for completion
opt.completeopt = "menuone,noselect" -- Show popup even with one item and don't autoselect first
if vim.fn.has("nvim-0.11") == 1 then
  o.completeopt = "menuone,noselect,fuzzy" -- Use fuzzy matching for built-in completion
end

opt.colorcolumn = "+1" -- Draw colored column one step to the right of desired maximum width
opt.conceallevel = 2 -- Hide * markup for bold and italic, but not markers with substitutions
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
o.cursorlineopt = "screenline,number" -- Show cursor line only screen line when wrapped
opt.expandtab = true -- Use spaces instead of tabs

-- Special UI symbols:
-- Note that "horiz", "horizup", "horizdown", "vertleft", "vertright" and
-- "verthoriz" are only used when 'laststatus' is 3, since only vertical
-- window separators are used otherwise.
o.fillchars = table.concat({
  "eob: ",
  "fold:╌",
  "horiz:═",
  "horizdown:╦",
  "horizup:╩",
  "vert:║",
  "verthoriz:╬",
  "vertleft:╣",
  "vertright:╠",
}, ",")

opt.foldmethod = "expr" -- TODO: "indent" perhaps?
opt.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevel = 1 -- Display all folds except top ones
o.foldnestmax = 10 -- Create folds only for some number of nested levels
-- o.foldtext = "" -- Use underlying text with its highlighting

-- Improve comment editing:
-- Changed: Added r,n, l, 1. Removed t and c
o.formatoptions = "rqnl1j"

opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.guicursor = "a:block"
opt.ignorecase = true -- Ignore case

-- Preview substitutions live, as you type!
opt.inccommand = "split" -- kickstart. Also: nosplit preview incremental substitute

o.infercase = true -- Infer letter cases for a richer built-in keyword completion
-- o.iskeyword     = '@,48-57,_,192-255,-' -- Treat dash separated words as a word text object
opt.jumpoptions = "view"
opt.laststatus = 2 -- 3 global statusline: on pick, filename disappears
opt.linebreak = true
opt.list = true -- Show some invisible characters (tabs...

-- Special text symbols:
o.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
-- Kickstart:
-- opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.mouse = "" -- Disable mouse mode
opt.number = true -- Print line number
-- opt.pumblend = 10 -- Popup blend
-- opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shada = "'100,<50,s10,:1000,/100,@100,h" -- Limit what is stored in ShaDa file
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent

-- Disable certain messages from |ins-completion-menu|
-- The default: "ltToOCF", or alphabetically: "CFOTlto"
-- Changed: Added S, W, a and c, Removed T, l and t
o.shortmess = "CFOSWaco"

opt.showmode = false -- Dont show mode since we have a statusline
opt.showtabline = 0 -- never show tabs, 1 is default, 2, -- always show tabs
-- opt.sidescrolloff = 6 -- Columns of context, used to be 8
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.smoothscroll = true
o.spelllang = "en,nl"
o.spelloptions = "camel"
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.timeoutlen = 600 -- 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.writebackup = false -- Don't store backup (better performance)

--          ╭─────────────────────────────────────────────────────────╮
--          │                         OTHER                           │
--          ╰─────────────────────────────────────────────────────────╯

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
vim.g.markdown_folding = 1 -- Use folding by heading in markdown files

-- checkhealth:
vim.g.python3_host_prog = "/usr/bin/python" -- archlinux: global python-pynvim

-- allow local .nvim.lua .vimrc .exrc files
-- vim.opt.exrc = true

-- checkhealth:
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0
