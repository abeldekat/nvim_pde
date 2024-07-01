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

local function make_header()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  return string.format("NVIM v%s.%s.%s", major, minor, patch)
end

local function make_footer(opts, footer_cb) opts.footer = footer_cb end

local function make_items()
  local section = "Commands"
  local items = {
    { action = Picker.keymaps, name = "Keymaps", section = section },
    { action = "Oil", name = "Oil(key 'mk')", section = section },
    { action = "qa", name = "Quit", section = section },
  }
  return {
    StarterOverride.recent_files_in_cwd(4), -- starter.sections.recent_files(5, true, false),
    items,
  }
end

-- Lazy loading mini.starter causes problems when using vim with stdin
function M.setup(extra_center, footer_cb)
  local opts = {
    evaluate_single = true,
    header = make_header(),
    items = make_items(),
    -- Removed the m for oil mk:
    query_updaters = "abcdefghijklnopqrstuvwxyz0123456789_-.",
  }
  vim.list_extend(opts.items, extra_center)
  make_footer(opts, footer_cb)
  Starter.setup(opts)
end

return M
