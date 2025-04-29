local o = vim.o

-- Leader key =================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.has("nvim-0.12") == 1 then
  vim.o.pummaxwidth = 80 -- Limit maximum width of popup menu
  vim.o.completefuzzycollect = "keyword,files,whole_line" -- Use fuzzy matching when collecting candidates
end

-- Completion =================================================================
o.complete = ".,w,b,kspell" -- use spell check and don't use tags for completion
o.completeopt = "menuone,noselect,fuzzy" -- show popup even with one item and don't autoselect first
o.wildmode = "longest:full,full" -- command-line completion mode

-- Editing ====================================================================
o.expandtab = true -- use spaces instead of tabs
o.formatoptions = "rqnl1j" -- improve comment editing. Added r,n, l, 1. Removed t and c
o.ignorecase = true -- ignore case
o.infercase = true -- infer letter cases for a richer built-in keyword completion
-- o.iskeyword     = '@,48-57,_,192-255,-' -- Treat dash separated words as a word text object
o.shiftwidth = 2 -- size of an indent
o.shiftround = true -- round indent
o.smartcase = true -- don't ignore case with capitals
o.smartindent = true -- insert indents automatically
o.tabstop = 2 -- number of spaces tabs count for
o.virtualedit = "block" -- allow going past the end of line in visual block mode

-- Folds ======================================================================
-- o.foldmethod = "expr" o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldmethod = "indent"
o.foldlevel = 99 -- 1: display all folds except top ones
o.foldnestmax = 10 -- create folds only for some number of nested levels
o.foldtext = "" -- use underlying text with its highlighting
vim.g.markdown_folding = 1 -- use folding by heading in markdown files

-- General ====================================================================
o.backup = false -- don't store backup
o.confirm = true -- confirm to save changes before exiting modified buffer
o.mouse = "" -- disable mouse impractical with laptop and touchpad
o.shada = "'100,<50,s10,:1000,/100,@100,h" -- limit what is stored in ShaDa file
-- o.switchbuf = "usetab" -- use already opened buffers when switching
o.timeoutlen = 600 -- 300
o.undofile = true
o.updatetime = 200 -- save swap file and trigger CursorHold
o.writebackup = false -- don't store backup (better performance)

-- Spelling ===================================================================
o.spelllang = "en,nl"
o.spelloptions = "camel"

-- UI =========================================================================
o.breakindent = true -- Indent wrapped lines to match line start
o.breakindentopt = "list:-1" -- Add padding for lists when 'wrap' is on
o.colorcolumn = "+1" -- Draw colored column one step to the right of desired maximum width
o.cursorline = true -- Enable highlighting of the current line
o.cursorlineopt = "screenline,number" -- show cursor line only screen line when wrapped
-- stylua: ignore start
o.fillchars = table.concat({ -- special UI symbols:
  "eob: ", "fold:╌", "horiz:═", "horizdown:╦", "horizup:╩", "vert:║",
  "verthoriz:╬", "vertleft:╣", "vertright:╠", }, ",")
-- stylua: ignore end
o.guicursor = "a:block"
-- Preview substitutions live, as you type!
o.inccommand = "split" -- kickstart. Also: nosplit preview incremental substitute
o.linebreak = true -- wrap long lines at 'breakat' (if 'wrap' is set)
o.list = true -- show helpful character indicators
o.listchars = table.concat({ "extends:…", "nbsp:␣", "precedes:…", "tab:> " }, ",")
o.number = true -- print line number
-- o.pumblend = 10 -- popup blend
o.pumheight = 10 -- maximum number of entries in a popup
o.relativenumber = true -- relative line numbers
o.ruler = false -- don't show cursor position
-- o.scrolloff = 4 -- lines of context
-- Default: "ltToOCF", or alphabetically: "CFOTlto". Added S, W, a and c, Removed T, l and t:
-- Also see mini.completion, suggested option values:
o.shortmess = "CFOSWaco" -- disable certain messages from |ins-completion-menu|
o.showmode = false -- don't show mode in command line
o.showtabline = 0 -- never show tabs, 1 is default, 2, -- always show tabs
o.signcolumn = "yes" -- always show signcolumn or it would frequently shift
o.splitbelow = true -- put new windows below current
o.splitkeep = "screen"
o.splitright = true -- put new windows right of current
o.laststatus = 3 -- global statusline on pick filename disappears
o.winborder = "rounded" -- since 0.11
o.wrap = false -- display long lines as just one line

-- Other settings =============================================================
vim.g.python3_host_prog = "/usr/bin/python" -- archlinux: global python-pynvim
vim.g.loaded_perl_provider = 0 -- checkhealth
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python3_provider = 0
-- allow local .nvim.lua .vimrc .exrc files:
-- vim.opt.exrc = true
vim.g.markdown_recommended_style = 0 -- fix markdown indentation settings
