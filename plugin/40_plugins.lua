local add, on_packchanged = vim.pack.add, Config.on_packchanged
local now_if_args, later, on_filetype = Config.now_if_args, Config.later, Config.on_filetype

-- Helpers ====================================================================
local gh = function(x) return 'https://github.com/' .. x end
local add_and_req = function(spec, loc)
  add(spec)
  require(loc)
end

-- Plugins included in MiniMax ================================================
now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  on_packchanged('nvim-treesitter', { 'update' }, ts_update, 'Update tree-sitter parsers')
  local spec_ts = { gh('nvim-treesitter/nvim-treesitter'), gh('nvim-treesitter/nvim-treesitter-textobjects') }
  add_and_req(spec_ts, 'ak.other.treesitter')
end)
now_if_args(function() add_and_req({ gh('neovim/nvim-lspconfig') }, 'ak.other.lsp') end)

later(function() add_and_req({ gh('stevearc/conform.nvim') }, 'ak.other.conform') end)
later(function() add({ gh('rafamadriz/friendly-snippets') }) end)

-- Plugins not included in MiniMax ============================================
now_if_args(function() add_and_req({ gh('mfussenegger/nvim-lint') }, 'ak.other.nvim_lint') end)
now_if_args(function() add({ gh('b0o/SchemaStore.nvim') }) end)

later(function() add_and_req({ gh('monaqa/dial.nvim') }, 'ak.other.dial') end)
later(function() add_and_req({ gh('stevearc/quicker.nvim') }, 'ak.other.quicker') end)
later(function() add_and_req({ gh('nvim-treesitter/nvim-treesitter-context') }, 'ak.other.treesitter_context') end)
later(function()
  require('ak.other.vimtex') -- set vimscript variables
  add({ gh('lervag/vimtex') })
end)

-- Filetype: markdown =========================================================
on_filetype('markdown', function()
  local build = function()
    vim.cmd.packadd('markdown-preview.nvim')
    vim.fn['mkdp#util#install']()
  end
  Config.on_packchanged('markdown-preview.nvim', { 'install', 'update' }, build, 'Build markdown-preview')
  -- latest commit 2 years ago
  add({ { src = gh('iamcco/markdown-preview.nvim'), version = 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee' } })
  -- Do not close the preview tab when switching to other buffers
  vim.g.mkdp_auto_close = 0
end)
