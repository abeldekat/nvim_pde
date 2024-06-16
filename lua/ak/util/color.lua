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
  end, { desc = "Highlights alternate" })
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

function M.builtins_to_skip()
  -- stylua: ignore
  return  { "zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
  "pablo", "murphy", "lunaperche", "koehler", "industry", "evening", "elflord",
  "desert", "delek", "darkblue", "blue", "sorbet", "morning", "wildcharm", "zaibatsu" }
end

-- Given the name of a spec, return the name of the config to require
function M.to_config_name(spec_name) return "ak.config.colors." .. spec_name:gsub("colors_", "") end

-- Given the name of a color, returns a table containing:
-- spec_name: The name of the spec, or nil
-- config_name: The full path of the config to require
function M.from_color_name(color_name) -- color names: ak.colors.txt
  local tmp = color_name
  local is_mini = false
  if tmp:find("fox", 1, true) then
    tmp = "nightfox" -- ie nordfox becomes nightfox
  elseif tmp:find("solarized8", 1, true) then
    tmp = "solarized8" -- ie solarized8_flat becomes solarized8
  elseif tmp:find("hue", 1, true) then
    tmp = "mini"
    is_mini = true
  elseif tmp:find("mini", 1, true) then
    tmp = "mini"
    is_mini = true
  end

  return {
    spec_name = not is_mini and ("colors_" .. tmp) or nil, -- startup plugin
    config_name = "ak.config.colors." .. tmp,
  }
end

return M
