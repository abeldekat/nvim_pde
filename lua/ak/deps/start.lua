local MiniDeps = require("mini.deps")
local Util = require("ak.util")
local now, later = MiniDeps.now, MiniDeps.later
local now_if_dir_arg = Util.opened_with_dir_argument() and now or later

now(function()
  require("ak.config.start.options_ak")
  require("ak.config.start.autocmds_ak")
  require("ak.config.start.misc") -- ie last cursor position autocmd
end)

now_if_dir_arg(function() require("ak.config.start.icons") end)

later(function()
  require("ak.config.start.keymaps_ak")
  require("ak.config.start.diagnostics")
  require("ak.config.start.basics") -- not using options and autocmd, so load later...
  require("ak.config.start.notify") -- better installation process
  require("ak.config.start.extra") -- pickers and ai. Pickers are not registered.
  require("ak.config.start.keymap")
end)
