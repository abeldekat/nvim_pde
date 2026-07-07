-- Recommended in ~/.config/lazygit/config.yml:
-- Ensure that pressing 'e' in LazyGit does not spawn a new nvim instance.
-- os:
--   editPreset: "nvim-remote"
--
-- There are themes where the selected line hides the underlying text.
-- Add to the config:
-- gui:
--   theme:
--     selectedLineBgColor:
--       - reverse
--
-- Copied from nvim echasnovski and modified
Config.open_lazygit = function()
  vim.cmd('tabedit')
  vim.cmd('setlocal nonumber signcolumn=no')

  -- The `jk` keymap breaks navigation in LazyGit
  vim.api.nvim_create_autocmd('TermOpen', {
    once = true,
    callback = function(ev) vim.keymap.del('t', 'jk', { buf = ev.buf }) end,
  })

  local tab = vim.api.nvim_tabpage_get_number(0)
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart('lazygit', {
    term = true,
    on_exit = function()
      -- Explicit tabclose, needed in case ministarter is only buffer
      vim.cmd('silent! :tabclose ' .. tab)
      vim.cmd('silent! :bw ' .. buf)
      vim.cmd('silent! :checktime')
    end,
  })
  vim.cmd('startinsert')
  vim.b.minipairs_disable = true
end
