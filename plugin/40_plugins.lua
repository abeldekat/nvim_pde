local add, on_packchanged = vim.pack.add, _G.Config.on_packchanged
local later, now_if_args = _G.Config.later, _G.Config.now_if_args

local add_req = function(spec, loc) -- helper function
  add(spec)
  require(loc)
end

now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  local spec_ts = {
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
    { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  }
  on_packchanged('nvim-treesitter', { 'update' }, ts_update, 'Update tree-sitter parsers')
  add_req(spec_ts, 'ak.other.treesitter')

  add_req({ 'https://github.com/neovim/nvim-lspconfig' }, 'ak.other.lsp')
end)

later(function()
  add_req({ 'https://github.com/stevearc/conform.nvim' }, 'ak.other.conform')
  add({ 'https://github.com/rafamadriz/friendly-snippets' })
end)

-- Plugins not included in MiniMax ============================================

now_if_args(function()
  add_req({ 'https://github.com/mfussenegger/nvim-lint' }, 'ak.other.nvim_lint')
  add({ 'https://github.com/b0o/SchemaStore.nvim' })
end)

later(function()
  add_req({ 'https://github.com/monaqa/dial.nvim' }, 'ak.other.dial')
  add_req({ 'https://github.com/stevearc/quicker.nvim' }, 'ak.other.quicker')
  add_req({ 'https://github.com/nvim-treesitter/nvim-treesitter-context' }, 'ak.other.treesitter_context')

  require('ak.other.vimtex') -- vimscript variables
  add({ 'https://github.com/lervag/vimtex' })

  local build_mkdp = function() vim.fn['mkdp#util#install']() end
  local spec_mkdp = {
    src = 'https://github.com/iamcco/markdown-preview.nvim',
    version = 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee', -- latest commit 2 years ago
  }
  on_packchanged('markdown-preview.nvim', { 'install', 'update' }, build_mkdp, 'Build markdown-preview')
  add({ spec_mkdp })
end)
