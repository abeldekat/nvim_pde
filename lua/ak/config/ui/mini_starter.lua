local M = {}

local Starter = require("mini.starter")
local Picker = require("ak.util").pick
local StarterOverride = {}

-- Optimized recent_files, only testing for filereadable on items < n
StarterOverride.recent_files_in_cwd = function(n)
  return function()
    local section = "Recent files (cwd)"
    local cwd = vim.fn.getcwd() .. "/"
    local items = {}
    for _, f in ipairs(vim.v.oldfiles or {}) do
      if #items == n then break end
      if vim.fn.filereadable(f) == 1 and vim.startswith(f, cwd) then
        table.insert(items, { action = "edit " .. f, name = vim.fn.fnamemodify(f, ":t"), section = section })
      end
    end

    local msg = "There are no recent files in current directory"
    return #items == 0 and { { name = msg, action = "", section = section } } or items
  end
end

local function header_cb()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  return string.format("NVIM v%s.%s.%s", major, minor, patch)
end

-- Lazy loading mini.starter causes problems when using vim with stdin
-- Keymap "mk"(oil) is not available when letter m is in query_updaters
-- When using leap, the letter s cannot be a query updater
-- General problem: When a letter is removed from query_updaters
-- that letter is still highlighted
function M.setup(package_manager, footer_cb)
  local section_commands = "Commands"
  local commands = {
    { action = "Oil", name = "Explore (key 'mk')", section = section_commands },
    { action = Picker.keymaps, name = "Keymaps", section = section_commands },
    { action = "qa", name = "Quit", section = section_commands },
  }
  local recent_files = StarterOverride.recent_files_in_cwd(4)

  local opts = {
    content_hooks = {
      Starter.gen_hook.aligning("center", "center"),
      Starter.gen_hook.indexing("all", { section_commands }),
    },
    evaluate_single = true,
    footer = footer_cb,
    header = header_cb,
    items = { recent_files, package_manager, commands },
    query_updaters = "ekq0123456789",
  }
  Starter.setup(opts)
end

return M
