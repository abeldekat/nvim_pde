--          ╭─────────────────────────────────────────────────────────╮
--          │           Module containing color utilities             │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.color
local M = {}

local Toggle = {}

function Toggle.add_toggle(opts)
  if Toggle.name and Toggle.name == opts.name then return end

  Toggle.name = opts.name
  Toggle.current = 1

  vim.keymap.set("n", opts.key and opts.key or "<leader>h", function()
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
  end, { desc = "Change hue" })
end

---@param name string
---@param bg? boolean
---@return string?
function M.color_hl(name, bg)
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  local color = nil
  if hl then
    color = bg and hl.bg or hl.fg -- hl.background hl.foreground undefined
  end
  return color and string.format("#%06x", color) or nil
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
    ---@diagnostic disable-next-line: redundant-parameter
    return vim.tbl_filter(function(color) return not vim.tbl_contains(builtins, color) end, target("", "color"))
  end

  vim.cmd("Telescope colorscheme enable_preview=true")
  vim.fn.getcompletion = target
end

-- Given the name of a spec, return the name of the config to require
function M.to_config_name(spec_name) return "ak.config.colors." .. spec_name:gsub("colors_", "") end

-- Given a name, returns a table containing:
-- name: The name of the color
-- spec_name: The name of the spec
-- config_name: The full path of the config to require
function M.from_color_name(color_name) -- color names: ak.colors.txt
  local name = color_name
  if name:find("fox", 1, true) then
    name = "nightfox" -- ie nordfox becomes nightfox
  elseif name:find("solarized8", 1, true) then
    name = "solarized8" -- ie solarized8_flat becomes solarized8
  end

  return {
    name = color_name,
    spec_name = "colors_" .. name,
    config_name = "ak.config.colors." .. name,
  }
end

return M
