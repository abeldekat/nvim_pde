---@diagnostic disable: duplicate-set-field

if vim.fn.has('nvim-0.12') == 0 then return end

-- Define custom `vim.pack.add()` hook helper. Copied from nvim echasnovski.
_G.Config.on_packchanged = function(plugin_name, kinds, callback, desc)
  local f = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then return end
    if not ev.data.active then vim.cmd.packadd(plugin_name) end
    callback()
  end
  _G.Config.new_autocmd('PackChanged', '*', f, desc)
end

-- UI options =================================================================

vim.o.pummaxwidth = 100 -- Limit maximum width of popup menu
vim.o.pumborder = 'bold' -- Use border in built-in completion menu
vim.o.winborder = 'bold' -- Use border in floating windows

-- require('vim._extui').enable({}) -- enter window with g<. See also option cmdheight

-- Keymaps ====================================================================

local nmap = function(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { desc = desc }) end
-- Paste linewise before/after current line
-- Usage: `yiw` to yank a word and `]p` to put it on the next line.
nmap('[p', '<Cmd>exe "iput! " . v:register<CR>', 'Paste Above')
nmap(']p', '<Cmd>exe "iput "  . v:register<CR>', 'Paste Below')
