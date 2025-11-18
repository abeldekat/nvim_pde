if vim.fn.has('nvim-0.12') == 0 then return end

-- Test `nvim undotree`...

-- UI options =================================================================

vim.o.pummaxwidth          = 100                        -- Limit maximum width of popup menu
vim.o.completefuzzycollect = 'keyword,files,whole_line' -- Use fuzzy matching when collecting candidates
vim.o.pumborder            = 'bold'                     -- Use border in built-in completion menu
vim.o.winborder            = 'bold'                     -- Use border in floating windows

require('vim._extui').enable({ enable = true })

-- Keymaps ====================================================================

local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap('[p', '<Cmd>exe "iput! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "iput "  . v:register<CR>', 'Paste Below')
