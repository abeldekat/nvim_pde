local DepsDeferred = require("akmini.deps_deferred")
local later = MiniDeps.later
local now_only_if_no_arguments = vim.fn.argc(-1) == 0 and MiniDeps.now or function() end

vim.o.statusline = " " -- wait till statusline plugin is loaded

now_only_if_no_arguments(function() -- dashboard
  local deps_cmd = function(cmd)
    DepsDeferred.load_registered()
    vim.cmd(cmd)
  end

  local section = "Deps"
  local items = {
    { action = function() deps_cmd("DepsUpdate") end, name = "u. update", section = section },
    { action = function() deps_cmd("DepsSnapSave") end, name = "a. snapSave", section = section },
    { action = function() deps_cmd("DepsClean") end, name = "c. clean", section = section },
  }
  require("ak.ui.starter").setup({ section = section, items = items, query_updaters = "uac" })
end)

later(function()
  require("ak.ui.statusline")
  require("ak.ui.animate")
  require("ak.ui.cursorword")
  require("ak.ui.indentscope")
  require("ak.ui.hipatterns")
end)
