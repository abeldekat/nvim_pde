local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local now, later = MiniDeps.now, MiniDeps.later

vim.o.statusline = " " -- wait till statusline plugin is loaded

later(function()
  require("ak.config.ui.statusline")
  require("ak.config.ui.indentscope")
  require("ak.config.ui.animate")
end)

if Util.opened_with_arguments() then return end

local deps_cmd = function(cmd)
  Util.deps.load_registered()
  vim.cmd(cmd)
end
local update = function() deps_cmd("DepsUpdate") end
local save = function() deps_cmd("DepsSnapSave") end
local clean = function() deps_cmd("DepsClean") end
now(function()
  local section = "Deps"
  require("ak.config.ui.starter").setup({
    section = section,
    items = {
      { action = update, name = "u. update", section = section },
      { action = save, name = "a. snapSave", section = section },
      { action = clean, name = "c. clean", section = section },
    },
    query_updaters = "uac",
  })
end)
