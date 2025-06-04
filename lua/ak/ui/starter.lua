local M = {}

local Starter = require("mini.starter")
local Picker = require("akshared.pick")
local StarterOverride = {}

local function header_cb()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  return string.format("NVIM v%s.%s.%s", major, minor, patch)
end

-- Lazy loading mini.starter causes problems when using vim with stdin
-- Keymap "mk"(explorer) is not available when letter m is in query_updaters
-- When using the s to jump, the letter s cannot be a query updater
-- General problem: When a letter is removed from query_updaters
-- that letter is still highlighted
function M.setup(pm_opts)
  local recent_files = Starter.sections.recent_files(4, true, false)
  local commands_section = "Commands"
  local commands = {
    { action = "e .", name = "e. explore('mk')", section = commands_section },
    { action = Picker.keymaps, name = "k. keymaps", section = commands_section },
    { action = "qa", name = "q. quit", section = commands_section },
  }

  local opts = {
    content_hooks = {
      Starter.gen_hook.adding_bullet(),
      Starter.gen_hook.aligning("center", "center"),
      Starter.gen_hook.indexing("all", { pm_opts.section, commands_section }),
    },
    evaluate_single = true,
    footer = function() return "  Press space for the menu" end,
    header = header_cb,
    items = { recent_files, pm_opts.items, commands },
    query_updaters = pm_opts.query_updaters .. "ekq123456789",
    silent = true, -- works better with pickers
  }
  Starter.setup(opts)
end

return M
