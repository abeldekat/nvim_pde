local now, later = Config.now, Config.later
local add = vim.pack.add

-- Traverse the variants of a colorscheme
local cmd_colorscheme = function(variant) vim.cmd.colorscheme(variant) end
local cache = {}
Config.add_theme_info = function(pattern, info, desc) -- see lua.ak.colors.*
  local set = function()
    if cache.name == info.name then return end

    cache.name = info.name
    cache.variants = info.variants
    cache.idx = 1
    cache.cb = info.cb and info.cb or cmd_colorscheme
  end
  Config.new_autocmd('ColorScheme', pattern, set, desc)
end
Config.next_theme_variant = function() -- see plugin.20_keymaps
  if not cache.idx then return end

  cache.idx = cache.idx == #cache.variants and 1 or (cache.idx + 1)
  local variant = cache.variants[cache.idx]

  -- Activate colorscheme:
  cache.cb(variant)
  vim.notify(string.format('Using %s[%s]', cache.name, vim.inspect(variant)))
end

-- Extra colorscheme plugins to install
local specs = {
  catppuccin = { src = 'https://github.com/catppuccin/nvim', name = 'colors_catppuccin' },
  everforest = { src = 'https://github.com/sainnhe/everforest', name = 'colors_everforest' },
  ['gruvbox-material'] = { src = 'https://github.com/sainnhe/gruvbox-material', name = 'colors_gruvbox-material' },
  melange = { src = 'https://github.com/savq/melange-nvim', name = 'colors_melange' },
  nightfox = { src = 'https://github.com/edeneast/nightfox.nvim', name = 'colors_nightfox' },
  thorn = { src = 'https://github.com/jpwol/thorn.nvim', name = 'colors_thorn' },
}

-- Return the name of the config to require
local to_config_name = function(color_name)
  local config_name = color_name
  if vim.tbl_contains({ 'minischeme', 'minicyan' }, config_name) then
    config_name = 'base16'
  elseif config_name:find('mini', 1, true) or config_name == 'randomhue' then
    config_name = 'hues'
  elseif config_name:find('catppuccin', 1, true) then
    config_name = 'catppuccin'
  elseif config_name:find('fox', 1, true) then
    config_name = 'nightfox'
  end
  return config_name
end

-- Set startup colorscheme
now(function()
  -- Colors.txt contains available color names
  local color_name = require('ak.color').color
  local config_name = to_config_name(color_name)

  -- Add the plugin if not from mini.nvim
  local spec = specs[config_name]
  if spec then add({ spec }) end

  -- Setup and apply
  require('ak.colors.' .. config_name)
  vim.cmd.colorscheme(color_name)
end)

-- Defer acting on other colorschemes
later(function()
  -- Add all colorschemes plugins
  add(vim.tbl_values(specs))

  -- Function ensuring all colorschemes have been configured(see pick colorschemes)
  local all_colors_setup = false
  local setup_all_colors = function()
    if all_colors_setup then return end

    vim.iter(specs):each(function(config_name, _) require('ak.colors.' .. config_name) end)
    require('ak.colors.base16') -- mini
    require('ak.colors.hues') -- mini
    all_colors_setup = true
  end
  Config.setup_all_colors = setup_all_colors
end)
