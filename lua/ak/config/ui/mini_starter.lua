local M = {}

local MiniStarter = require("mini.starter")
local Picker = require("ak.util").pick

local function make_header()
  -- Header to be displayed before items. Converted to single string via
  -- `tostring` (use `\n` to display several lines). If function, it is
  -- evaluated first. If `nil` (default), polite greeting will be used.
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""

  -- local prerelease = versioninfo.api_prerelease and "-dev" or ""
  -- return string.format("NVIM v%s.%s.%s%s", major, minor, patch, prerelease)
  return string.format("NVIM v%s.%s.%s", major, minor, patch)
end

local function make_footer(opts, footer_cb)
  -- Footer to be displayed after items. Converted to single string via
  -- `tostring` (use `\n` to display several lines). If function, it is
  -- evaluated first. If `nil` (default), default usage help will be shown.
  opts.footer = footer_cb
end

local function make_items()
  -- Items to be displayed. Should be an array with the following elements:
  -- - Item: table with <action>, <name>, and <section> keys.
  -- - Function: should return one of these three categories.
  -- - Array: elements of these three types (i.e. item, array, function).
  -- If `nil` (default), default items will be used (see |mini.starter|).
  local section = "Navigation"
  return {
    {
      action = Picker.find_files,
      name = "Files fuzzy",
      section = section,
    },
    {
      action = Picker.live_grep,
      name = "Live grep",
      section = section,
    },
    {
      action = Picker.keymaps,
      name = "Keymaps",
      section = section,
    },
    {
      action = Picker.oldfiles,
      name = "Recent files",
      section = section,
    },
    {
      action = "Oil",
      name = "Oil(key 'mk')",
      section = section,
    },
    {
      action = "qa",
      name = "Quit",
      section = section,
    },
  }
end

local function make_content_hooks()
  -- Array  of functions to be applied consecutively to initial content.
  -- Each function should take and return content for 'Starter' buffer (see
  -- |mini.starter| and |MiniStarter.get_content()| for more details).
  return nil -- the default
end

local function get_opts()
  local config = {
    -- Whether to open starter buffer conditionally on VimEnter.
    autoopen = true, -- default true
    -- Whether to evaluate action of single active item
    evaluate_single = true, -- default false

    items = make_items(),
    header = make_header(),
    footer = nil, -- set later
    content_hooks = make_content_hooks(),

    -- Characters to update query. Each character will have special buffer
    -- mapping overriding your global ones. Be careful to not add `:` as it
    -- allows you to go into command mode.
    query_updaters = "fkloqr123",

    -- Whether to disable showing non-error feedback
    -- silent = false, -- default false
  }
  return config
end

-- Lazy loading mini.starter causes problems when using vim with stdin
function M.setup(extra_center, footer_cb)
  local opts = get_opts()

  vim.list_extend(opts.items, extra_center)
  make_footer(opts, footer_cb)
  MiniStarter.setup(opts)
end

return M
