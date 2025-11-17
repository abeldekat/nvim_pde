local function header_cb()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  return string.format("NVIM v%s.%s.%s", major, minor, patch)
end

local Starter = require("mini.starter")
local recent_files = Starter.sections.recent_files(4, true, false)

local commands_section = "Commands"
local commands_items = {
  { action = "qa", name = "q. quit", section = commands_section },
}

local deps_section = "Deps"
local deps_cmd = function(cmd)
  require("akmini.deps_deferred").load_registered()
  vim.cmd(cmd)
end
local deps_items = {
  { action = function() deps_cmd("DepsUpdate") end, name = "u. update", section = deps_section },
  { action = function() deps_cmd("DepsSnapSave") end, name = "a. snapSave", section = deps_section },
  { action = function() deps_cmd("DepsClean") end, name = "c. clean", section = deps_section },
}

local opts = {
  content_hooks = {
    Starter.gen_hook.adding_bullet(),
    Starter.gen_hook.aligning("center", "center"),
    Starter.gen_hook.indexing("all", { deps_section, commands_section }),
  },
  evaluate_single = true,
  footer = function() return "  Press space for the menu" end,
  header = header_cb,
  items = { recent_files, deps_items, commands_items },
  query_updaters = "uacq123456789",
  silent = true, -- works better with pickers
}
Starter.setup(opts)
