vim.cmd('setlocal spell')
vim.cmd('setlocal wrap')
vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()') -- foldlevel=1

-- Disable built-in `gO` mapping in favor of 'mini.basics'
vim.keymap.del('n', 'gO', { buffer = 0 })

-- Set markdown-specific surrounding in 'mini.surround'
vim.b.minisurround_config = {
  custom_surroundings = {
    -- Markdown link. Common usage:
    -- `saiwL` + [type/paste link] + <CR> - add link
    -- `sdL` - delete link
    -- `srLL` + [type/paste link] + <CR> - replace link
    L = {
      input = { '%[().-()%]%(.-%)' },
      output = function()
        local link = require('mini.surround').user_input('Link: ')
        return { left = '[', right = '](' .. link .. ')' }
      end,
    },
  },
}

-- vim.cmd("setlocal conceallevel=2") -- Hide * markup for bold and italic, but not markers with substitutions

local has_mini_ai, mini_ai = pcall(require, 'mini.ai')
if not has_mini_ai then return end
vim.b.miniai_config = {
  custom_textobjects = {
    S = { '```().-()```' },
    ['*'] = mini_ai.gen_spec.pair('*', '*', { type = 'greedy' }),
    ['_'] = mini_ai.gen_spec.pair('_', '_', { type = 'greedy' }),
  },
}
