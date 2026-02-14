---@diagnostic disable: duplicate-set-field

-- Monkey patch `vim.pack.add` for compatibility with Neovim<0.12 to only load plugins.
-- Manage them (install, update, delete) on Neovim>=0.12. Copied from nvim echasnovski.
if vim.fn.has('nvim-0.12') == 0 then
  vim.pack = {}
  vim.pack.add = function(specs, opts)
    specs = vim.tbl_map(function(s) return type(s) == 'string' and { src = s } or s end, specs)
    ---@diagnostic disable-next-line: undefined-field
    opts = vim.tbl_extend('force', { load = vim.v.did_init == 1 }, opts or {})

    local cmd_prefix = 'packadd' .. (opts.load and '' or '!')
    for _, s in ipairs(specs) do
      local name = s.name or s.src:match('/([^/]+)$')
      vim.cmd(cmd_prefix .. name)
    end
  end
end

-- Added: Optimize
for _, disable in ipairs({ 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' }) do
  vim.g['loaded_' .. disable] = 0
end

-- Install 'mini.nvim'
vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' })

-- Define config table to be able to pass data between scripts
_G.Config = {}

local gr = vim.api.nvim_create_augroup('custom-config', {})
Config.new_autocmd = function(event, pattern, callback, desc)
  local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
  vim.api.nvim_create_autocmd(event, opts)
end

-- Set up 'mini.deps' to have its `now()` and `later()` helpers
require('mini.deps').setup()
Config.now_if_args = vim.fn.argc(-1) > 0 and MiniDeps.now or MiniDeps.later
Config.now, Config.later = MiniDeps.now, MiniDeps.later

-- Define dummy `vim.pack.add()` hook helper. See 28_nightly.lua
Config.on_packchanged = function() end
