local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local now, later = MiniDeps.now, MiniDeps.later

vim.o.statusline = " " -- wait till statusline plugin is loaded

later(function()
  require("ak.config.ui.mini_statusline")
  require("ak.config.ui.mini_indentscope")
  require("ak.config.ui.mini_animate") -- PERF: :Startuptime is slower....
end)

if Util.opened_with_arguments() then return end
now(function()
  local section = "Deps"
  require("ak.config.ui.mini_starter").setup({
    section = section,
    items = {
      { action = "DepsUpdate", name = "u. update", section = section },
      { action = "DepsSnapSave", name = "a. snapSave", section = section },
      { action = "DepsClean", name = "c. clean", section = section },
    },
    query_updaters = "uac",
  })
end)
