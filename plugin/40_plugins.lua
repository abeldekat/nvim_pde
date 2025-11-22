local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

local addreq = function(spec, loc)
  add(spec)
  require(loc)
end

now_if_args(function()
  add({
    source = 'nvim-treesitter/nvim-treesitter',
    checkout = 'main',
    hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
  })
  add({
    source = 'nvim-treesitter/nvim-treesitter-textobjects',
    checkout = 'main',
  })
  require('ak.other.treesitter')

  addreq('neovim/nvim-lspconfig', 'ak.other.lsp')
end)

later(function()
  addreq('stevearc/conform.nvim', 'ak.other.conform')
  add('rafamadriz/friendly-snippets')
end)

-- Plugins not included in MiniMax ============================================

-- TODO: Add nvim-lint? Move the definition of keymaps?
later(function()
  addreq('monaqa/dial.nvim', 'ak.other.dial')
  addreq('stevearc/quicker.nvim', 'ak.other.quicker')
  addreq('nvim-treesitter/nvim-treesitter-context', 'ak.other.treesitter_context')
  add('b0o/SchemaStore.nvim')

  require('ak.other.vimtex') -- sets vimscript variables
  add('lervag/vimtex')

  local build_mkdp = function() vim.fn['mkdp#util#install']() end
  add({
    source = 'iamcco/markdown-preview.nvim',
    hooks = {
      post_install = function() later(build_mkdp) end,
      post_checkout = build_mkdp,
    },
    checkout = 'a923f5fc5ba36a3b17e289dc35dc17f66d0548ee', -- latest commit 2 years ago
  })
  vim.g.mkdp_auto_close = 0
end)
