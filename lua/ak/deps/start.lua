local MiniDeps = require("mini.deps")
local Util = require("ak.util")
local now, later = MiniDeps.now, MiniDeps.later

local function icons() require("ak.config.start.icons") end -- cmp, explorer, etc...

now(function()
  require("ak.config.start.options")
  require("ak.config.start.autocmds")
  require("ak.config.start.misc") -- ie last cursor position autocmd
end)

if Util.opened_with_dir_argument() then
  now(icons)
else
  later(icons)
end

later(function()
  require("ak.config.start.keymaps")
  require("ak.config.start.diagnostics")
  require("ak.config.start.basics") -- not using options and autocmd, so load later...
  require("ak.config.start.notify") -- better installation process
  require("ak.config.start.extra") -- pickers and ai. Pickers are not registered.
end)
