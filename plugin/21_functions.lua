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

  -- This buffer needs to be deleted when job is finished
  local buf = vim.api.nvim_get_current_buf()

  -- The `jk` keymap breaks navigation in LazyGit
  vim.api.nvim_create_autocmd('TermOpen', {
    once = true,
    callback = function(ev) vim.keymap.del('t', 'jk', { buf = ev.buf }) end,
  })

  vim.fn.jobstart('lazygit', {
    term = true,
    on_exit = function()
      vim.cmd('silent! :checktime')
      vim.cmd('silent! :bw ' .. buf)
    end,
  })
  vim.cmd('startinsert')
  vim.b.minipairs_disable = true
end
