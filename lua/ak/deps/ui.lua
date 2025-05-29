-- Appearance
local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local later = MiniDeps.later
local now_only_if_no_arguments = vim.fn.argc(-1) == 0 and MiniDeps.now or function() end

vim.o.statusline = " " -- wait till statusline plugin is loaded

now_only_if_no_arguments(function()
  local deps_cmd = function(cmd)
    Util.deps.load_registered()
    vim.cmd(cmd)
  end

  local section = "Deps"
  local items = {
    { action = function() deps_cmd("DepsUpdate") end, name = "u. update", section = section },
    { action = function() deps_cmd("DepsSnapSave") end, name = "a. snapSave", section = section },
    { action = function() deps_cmd("DepsClean") end, name = "c. clean", section = section },
  }
  require("ak.config.ui.starter").setup({ section = section, items = items, query_updaters = "uac" })
end)

later(function()
  require("ak.config.ui.statusline")
  require("ak.config.ui.animate")
  require("ak.config.ui.cursorword")
  require("ak.config.ui.indentscope")
  require("ak.config.ui.hipatterns")
end)
