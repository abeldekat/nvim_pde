local add = vim.pack.add
local now, later = Config.now, Config.later
local all_colors_setup = false
local Color = require('ak.color') -- contains color info set by shell script and rofi. See colors.txt

local specs = {
  catppuccin = { src = 'https://github.com/catppuccin/nvim', name = 'colors_catppuccin' },
  everforest = { src = 'https://github.com/sainnhe/everforest', name = 'colors_everforest' },
  ['gruvbox-material'] = { src = 'https://github.com/sainnhe/gruvbox-material', name = 'colors_gruvbox-material' },
  nightfox = { src = 'https://github.com/edeneast/nightfox.nvim', name = 'colors_nightfox' },
  thorn = { src = 'https://github.com/jpwol/thorn.nvim', name = 'colors_thorn' },
}

-- Given the name of a color, returns a table containing:
-- spec_name: The name of the spec, or nil
-- config_name: The full path of the config to require
local to_config_name = function(color_name) -- color names: ak.colors.txt
  local config_name = color_name
  if vim.tbl_contains({ 'minischeme', 'minicyan' }, config_name) then
    config_name = 'base16'
  elseif config_name:find('mini', 1, true) or config_name == 'randomhue' then
    config_name = 'hues'
  elseif config_name:find('catppuccin', 1, true) then
    config_name = 'catppuccin'
  elseif config_name:find('fox', 1, true) then
    config_name = 'nightfox' -- ie nordfox becomes nightfox
  end
  return config_name
end

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
  Config.new_autocmd('ColorScheme', pattern, function() new_theme(new_info) end, desc)
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
Config.add_theme_info = add_theme_info -- see ak.colors
Config.next_theme_variant = next_variant -- see 20_keymaps

now(function()
  local config_name = to_config_name(Color.color)

  -- Add plugins other than mini
  local spec = specs[config_name]
  if spec then add({ spec }) end

  -- Setup and apply
  require('ak.colors.' .. config_name)
  vim.cmd.colorscheme(Color.color)
end)

later(function()
  add(vim.tbl_values(specs))

  local setup_all_colors = function() -- See pick colorschemes
    if all_colors_setup then return end
    for config_name, _ in pairs(specs) do -- Load all specs and their configs
      require('ak.colors.' .. config_name)
    end
    require('ak.colors.base16') -- mini
    require('ak.colors.hues') -- mini
    all_colors_setup = true
  end
  Config.setup_all_colors = setup_all_colors
end)
