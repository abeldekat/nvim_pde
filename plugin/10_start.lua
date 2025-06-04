local now, later, add = MiniDeps.now, MiniDeps.later, MiniDeps.add
local now_if_args = vim.fn.argc(-1) > 0 and now or later

now(function()
  require("ak.start.options_ak")
  require("ak.start.autocmds_ak")
  require("ak.start.misc") -- ie last cursor position autocmd
end)

now_if_args(function() -- no need for treesitter on the dashboard
  local ts_ak = require("ak.start.treesitter")
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    -- post_install triggers before packadd...
    -- post_checkout only triggers if update differs from version in mini-deps-snap...
    hooks = { post_install = vim.schedule_wrap(ts_ak.install_or_update), post_checkout = ts_ak.install_or_update },
  })
  ts_ak.setup()
end)

later(function()
  require("ak.start.keymaps_ak")
  require("ak.start.icons")
  require("ak.start.diagnostics")
  require("ak.start.basics") -- not using options and autocmd, so load later...
  require("ak.start.notify") -- better installation process
  require("ak.start.extra") -- pickers and ai. Pickers are not registered.
  require("ak.start.keymap") -- mini.keymap...
end)
