local DeferredDeps = require('akextra.deps_deferred')
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local Color = require('ak.color') -- contains color info set by shell script and rofi. See colors.txt
local all_colors_loaded = false -- before picking other colors all need to be added

local specs = {
  { source = 'catppuccin/nvim', name = 'colors_catppuccin' },
  { source = 'Shatur/neovim-ayu', name = 'colors_ayu' },
  { source = 'ribru17/bamboo.nvim', name = 'colors_bamboo' },
  { source = 'savq/melange-nvim', name = 'colors_melange' },
  { source = 'sainnhe/everforest', name = 'colors_everforest' },
  { source = 'sainnhe/gruvbox-material', name = 'colors_gruvbox-material' },
  { source = 'EdenEast/nightfox.nvim', name = 'colors_nightfox' },
  { source = 'folke/tokyonight.nvim', name = 'colors_tokyonight' },
  -- { source = "rose-pine/neovim", name = "colors_rose-pine" },
  -- { source = "sainnhe/sonokai", name = "colors_sonokai" },
  -- { source = "navarasu/onedark.nvim", name = "colors_onedark" },
  -- { source = "rebelot/kanagawa.nvim", name = "colors_kanagawa" },
  -- { source = "craftzdog/solarized-osaka.nvim", name = "colors_solarized-osaka" },
  -- { source = "ellisonleao/gruvbox.nvim", name = "colors_gruvbox" },
  -- { source = "lifepillar/vim-solarized8", name = "colors_solarized8", checkout = "neovim" },
}


local register_all_colors = function()
  vim.iter(specs):each(function(s) DeferredDeps.register(s) end)
end

local find_spec = function(spec_name)
  return vim.iter(specs):filter(function(s) return s.name == spec_name end):totable()[1]
end

-- Given the name of a color, returns a table containing:
-- spec_name: The name of the spec, or nil
-- config_name: The full path of the config to require
local from_color_name = function(color_name) -- color names: ak.colors.txt
  local tmp = color_name
  local is_mini = false
  if tmp:find('fox', 1, true) then
    tmp = 'nightfox' -- ie nordfox becomes nightfox
  elseif tmp:find('solarized8', 1, true) then
    tmp = 'solarized8' -- ie solarized8_flat becomes solarized8
  elseif tmp:find('hue', 1, true) then
    tmp = 'mini'
    is_mini = true
  elseif tmp:find('mini', 1, true) then
    tmp = 'mini'
    is_mini = true
  end

  return {
    spec_name = not is_mini and ('colors_' .. tmp) or nil, -- startup plugin
    config_name = 'ak.colors.' .. tmp,
  }
end

-- Given the name of a spec, return the name of the config to require
local to_config_name = function(spec_name) return 'ak.colors.' .. spec_name:gsub('colors_', '') end

local setup_all_colors = function()
  if all_colors_loaded then return end
  for _, spec in ipairs(specs) do -- Load all specs and their configs
    add(spec)
    require(to_config_name(spec.name))
  end
  require(from_color_name('mini').config_name) -- Mini collection
  all_colors_loaded = true
end
_G.Config.setup_all_colors = setup_all_colors

now(function()
  local info = from_color_name(Color.color)
  local spec = info.spec_name and find_spec(info.spec_name)

  if spec then add(spec) end
  require(info.config_name)
  vim.cmd.colorscheme(Color.color)
end)

later(function() register_all_colors() end)
