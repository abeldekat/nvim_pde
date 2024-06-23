local M = {}

local Starter = require("mini.starter")
local Picker = require("ak.util").pick
local StarterOverride = {}

-- Only test as many items in v:oldfiles as are needed. Removed show_path
StarterOverride.recent_files = function(n, current_dir) -- show_path
  local function is_readable_filter(f) return vim.fn.filereadable(f) == 1 end
  local function make_in_cwd_filter()
    local sep = vim.loop.os_uname().sysname == "Windows_NT" and [[%\]] or "%/"
    local cwd_pattern = "^" .. vim.pesc(vim.fn.getcwd()) .. sep
    return function(f) return f:find(cwd_pattern) ~= nil end
  end
  return function()
    local section = string.format("Recent files%s", current_dir and " (cwd)" or "")
    local filters = { is_readable_filter }
    if current_dir then filters[#filters + 1] = make_in_cwd_filter() end

    local files = {}
    for _, f in ipairs(vim.v.oldfiles or {}) do
      if #files == n then break end
      local add = true
      for _, filter in ipairs(filters) do
        add = add and filter(f)
        if not add then break end
      end
      if add then files[#files + 1] = f end
    end

    if #files == 0 then
      local msg = "There are no recent files (`v:oldfiles` is empty)"
      if current_dir then msg = "There are no recent files in current directory" end
      return { { name = msg, action = "", section = section } }
    end

    local items = {} -- Create items
    for _, f in ipairs(files) do
      local name = vim.fn.fnamemodify(f, ":t") --  .. show_path(f)
      table.insert(items, { action = "edit " .. f, name = name, section = section })
    end
    return items
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
    StarterOverride.recent_files(4, true), -- starter.sections.recent_files(5, true, false),
    items,
  }
end

-- Lazy loading mini.starter causes problems when using vim with stdin
function M.setup(extra_center, footer_cb)
  local opts = {
    evaluate_single = true,
    items = make_items(),
    header = make_header(),
  }
  vim.list_extend(opts.items, extra_center)
  make_footer(opts, footer_cb)
  Starter.setup(opts)
end

return M
