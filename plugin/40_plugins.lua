local add, on_packchanged = vim.pack.add, Config.on_packchanged
local later, now_if_args = Config.later, Config.now_if_args

local gh = function(x) return 'https://github.com/' .. x end
local add_and_req = function(spec, loc)
  add(spec)
  require(loc)
end

now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  on_packchanged('nvim-treesitter', { 'update' }, ts_update, 'Update tree-sitter parsers')
  local spec_ts = { gh('nvim-treesitter/nvim-treesitter'), gh('nvim-treesitter/nvim-treesitter-textobjects') }
  add_and_req(spec_ts, 'ak.other.treesitter')

  add_and_req({ gh('neovim/nvim-lspconfig') }, 'ak.other.lsp')
end)

later(function()
  add_and_req({ gh('stevearc/conform.nvim') }, 'ak.other.conform')
  add({ gh('rafamadriz/friendly-snippets') })
end)

-- Plugins not included in MiniMax ============================================

now_if_args(function()
  add_and_req({ gh('mfussenegger/nvim-lint') }, 'ak.other.nvim_lint')
  add({ gh('b0o/SchemaStore.nvim') })
end)

later(function()
  add_and_req({ gh('monaqa/dial.nvim') }, 'ak.other.dial')
  add_and_req({ gh('stevearc/quicker.nvim') }, 'ak.other.quicker')
  add_and_req({ gh('nvim-treesitter/nvim-treesitter-context') }, 'ak.other.treesitter_context')

  require('ak.other.vimtex') -- vimscript variables
  add({ gh('lervag/vimtex') })

  local build_mkdp = function() vim.fn['mkdp#util#install']() end
  on_packchanged('markdown-preview.nvim', { 'install', 'update' }, build_mkdp, 'Build markdown-preview')
  local spec_mkdp = {
    src = gh('iamcco/markdown-preview.nvim'),
    version = 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee', -- latest commit 2 years ago
  }
  add({ spec_mkdp })
end)
