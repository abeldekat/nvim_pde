--          ╭─────────────────────────────────────────────────────────╮
--          │           Module containing color utilities             │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.color
local M = {}

local Toggle = {}

function M.setup()
  Toggle.name = nil
  Toggle.current = 1
end

function Toggle.add_toggle(opts)
  if Toggle.name and Toggle.name == opts.name then return end

  Toggle.name = opts.name
  Toggle.current = 1

  vim.keymap.set("n", opts.key and opts.key or "<leader>a", function()
    Toggle.current = Toggle.current == #opts.flavours and 1 or (Toggle.current + 1)
    local flavour = opts.flavours[Toggle.current]

    if opts.toggle then
      opts.toggle(flavour)
    else
      vim.cmd.colorscheme(flavour)
    end

    vim.defer_fn(function()
      local info = string.format("Using %s[%s]", opts.name, vim.inspect(flavour))
      vim.api.nvim_echo({ { info, "InfoMsg" } }, true, {})
    end, 250)
  end, { desc = "Alternate colors" })
end

function M.add_toggle(pattern, toggle_opts)
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = type(pattern) == string and { pattern } or pattern,
    callback = function() Toggle.add_toggle(toggle_opts) end,
  })
end

function M.telescope_custom_colors()
  -- stylua: ignore
  local builtins = { "zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
  "pablo", "murphy", "lunaperche", "koehler", "industry", "evening", "elflord",
  "desert", "delek", "default", "darkblue", "blue" }

  local target = vim.fn.getcompletion

  ---@diagnostic disable-next-line: duplicate-set-field
  vim.fn.getcompletion = function()
    return vim.tbl_filter(function(color) return not vim.tbl_contains(builtins, color) end, target("", "color"))
  end

  vim.cmd("Telescope colorscheme enable_preview=true")
  vim.fn.getcompletion = target
end

-- Given a name, returns a table containing:
-- color_name: The name of the color
-- config_name: The full path of the config to require
function M.from_package_name(package_name)
  local name = package_name:gsub("colors_", "")
  return {
    color_name = name,
    config_name = "ak.config.colors." .. name,
  }
end

-- Given a name, returns a table containing:
-- package_name: The name of the package to packadd
-- config_name: The full path of the config to require
function M.from_color_name(color_name)
  local name = color_name
  if name:find("fox", 1, true) then
    name = "nightfox" -- ie nordfox becomes nightfox
  elseif name:find("solarized8", 1, true) then
    name = "solarized8" -- ie solarized8_flat becomes solarized8
  end

  return {
    package_name = "colors_" .. name,
    config_name = "ak.config.colors." .. name,
  }
end

return M
