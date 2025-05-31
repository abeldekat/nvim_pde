local MiniDeps = require("mini.deps")
local now, later, add = MiniDeps.now, MiniDeps.later, MiniDeps.add
local now_if_args = vim.fn.argc(-1) > 0 and now or later

now(function()
  require("ak.config.start.options_ak")
  require("ak.config.start.autocmds_ak")
  require("ak.config.start.misc") -- ie last cursor position autocmd
end)

now_if_args(function() -- no need for treesitter or icons on the dashboard
  local ts_ak = require("ak.config.start.treesitter")
  add({
    source = "nvim-treesitter/nvim-treesitter",
    checkout = "main",
    hooks = { post_checkout = ts_ak.install_or_update },
  })
  ts_ak.setup()
end)

later(function()
  require("ak.config.start.keymaps_ak")
  require("ak.config.start.icons")
  require("ak.config.start.diagnostics")
  require("ak.config.start.basics") -- not using options and autocmd, so load later...
  require("ak.config.start.notify") -- better installation process
  require("ak.config.start.extra") -- pickers and ai. Pickers are not registered.
  require("ak.config.start.keymap") -- mini.keymap...
end)
