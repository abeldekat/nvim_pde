local add = vim.pack.add
local now, later = _G.Config.now, _G.Config.later

local Color = require('ak.color') -- contains color info set by shell script and rofi. See colors.txt
local all_colors_loaded = false

local specs = {
  { src = 'https://github.com/catppuccin/nvim', name = 'colors_catppuccin' },
  { src = 'https://github.com/shatur/neovim-ayu', name = 'colors_ayu' },
  { src = 'https://github.com/ribru17/bamboo.nvim', name = 'colors_bamboo' },
  { src = 'https://github.com/savq/melange-nvim', name = 'colors_melange' },
  { src = 'https://github.com/sainnhe/everforest', name = 'colors_everforest' },
  { src = 'https://github.com/sainnhe/gruvbox-material', name = 'colors_gruvbox-material' },
  { src = 'https://github.com/edeneast/nightfox.nvim', name = 'colors_nightfox' },
  { src = 'https://github.com/uhs-robert/oasis.nvim', name = 'colors_oasis' },
  -- { src = 'https://github.com/rose-pine/neovim', name = 'colors_rose-pine' },
  -- { src = 'https://github.com/folke/tokyonight.nvim', name = 'colors_tokyonight' },
  -- { src = 'https://github.com/navarasu/onedark.nvim', name = "colors_onedark" },
  -- { src = 'https://github.com/rebelot/kanagawa.nvim', name = "colors_kanagawa" },
  -- { src = 'https://github.com/ellisonleao/gruvbox.nvim', name = "colors_gruvbox" },
  -- { src = 'https://github.com/lifepillar/vim-solarized8', name = "colors_solarized8", checkout = "neovim" },
}

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

-- Traverse the variants of a theme
local theme_info = {} -- contains name, variants and possible callback
local add_theme_info = function(pattern, new_info, desc)
  local theme_info_default_cb = function(variant) vim.cmd.colorscheme(variant) end
  local new_theme = function(info)
    if theme_info.name and theme_info.name == info.name then return end
    theme_info = info
    theme_info.idx = 1
    theme_info.cb = theme_info.cb and theme_info.cb or theme_info_default_cb
  end
  _G.Config.new_autocmd('ColorScheme', pattern, function() new_theme(new_info) end, desc)
end
local next_variant = function()
  theme_info.idx = theme_info.idx == #theme_info.variants and 1 or (theme_info.idx + 1)
  local variant = theme_info.variants[theme_info.idx]
  theme_info.cb(variant)
  vim.defer_fn(function()
    local msg = string.format('Using %s[%s]', theme_info.name, vim.inspect(variant))
    vim.api.nvim_echo({ { msg, 'InfoMsg' } }, true, {})
  end, 250)
end
_G.Config.add_theme_info = add_theme_info -- see ak.colors
_G.Config.next_theme_variant = next_variant -- see keymaps

now(function()
  local colorinfo = from_color_name(Color.color)
  local spec = colorinfo.spec_name and find_spec(colorinfo.spec_name)

  if spec then add({ spec }) end
  require(colorinfo.config_name)
  vim.cmd.colorscheme(Color.color)
end)

later(function()
  add(specs)

  local setup_all_colors = function() -- See pick colorschemes
    if all_colors_loaded then return end
    for _, spec in ipairs(specs) do -- Load all specs and their configs
      require(to_config_name(spec.name))
    end
    require(from_color_name('mini').config_name) -- Mini collection
    all_colors_loaded = true
  end
  _G.Config.setup_all_colors = setup_all_colors
end)
