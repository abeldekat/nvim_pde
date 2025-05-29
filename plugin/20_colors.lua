local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local Color = require("ak.color")

local colors_loaded = false
local H = {}

local setup = function()
  now(function()
    local info = H.from_color_name(Color.color)
    if info.spec_name then
      local spec = vim.iter(H.colors):filter(function(s) return s.name == info.spec_name end):totable()[1]
      add(spec)
    end
    H.cmd_colorscheme(Color.color, info)
  end)

  later(function()
    H.add_keymap_all_colors()
    vim.iter(H.colors):each(function(s) Util.deps.register(s) end)
  end)
end

H.cmd_colorscheme = function(color_name, info)
  Util.try(function()
    require(info.config_name)
    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg) Util.error(msg) end,
  })
end

H.colors = {
  { source = "catppuccin/nvim", name = "colors_catppuccin" },
  { source = "EdenEast/nightfox.nvim", name = "colors_nightfox" },
  { source = "ribru17/bamboo.nvim", name = "colors_bamboo" },
  { source = "savq/melange-nvim", name = "colors_melange" },
  { source = "sainnhe/everforest", name = "colors_everforest" },
  { source = "sainnhe/gruvbox-material", name = "colors_gruvbox-material" },
  { source = "folke/tokyonight.nvim", name = "colors_tokyonight" },
  { source = "rose-pine/neovim", name = "colors_rose-pine" },
  -- { source = "sainnhe/sonokai", name = "colors_sonokai" },
  -- { source = "navarasu/onedark.nvim", name = "colors_onedark" },
  -- { source = "rebelot/kanagawa.nvim", name = "colors_kanagawa" },
  -- { source = "sainnhe/edge", name = "colors_edge" },
  -- { source = "craftzdog/solarized-osaka.nvim", name = "colors_solarized-osaka" },
  -- { source = "ellisonleao/gruvbox.nvim", name = "colors_gruvbox" },
  -- { source = "Shatur/neovim-ayu", name = "colors_ayu" },
  -- { source = "lifepillar/vim-solarized8", name = "colors_solarized8", checkout = "neovim" },
  -- { source = "ronisbr/nano-theme.nvim", name = "colors_nano-theme" },
}

H.add_keymap_all_colors = function()
  vim.keymap.set("n", "<leader>foc", function()
    if not colors_loaded then
      for _, spec in ipairs(H.colors) do -- Load all specs and their configs
        add(spec)
        require(H.to_config_name(spec.name))
      end
      require(H.from_color_name("mini").config_name) -- Mini collection
      colors_loaded = true
    end

    vim.schedule(function() Util.pick.colors() end)
  end, { desc = "Colorscheme picker", silent = true })
end

-- Given the name of a spec, return the name of the config to require
H.to_config_name = function(spec_name) return "ak.config.colors." .. spec_name:gsub("colors_", "") end

-- Given the name of a color, returns a table containing:
-- spec_name: The name of the spec, or nil
-- config_name: The full path of the config to require
H.from_color_name = function(color_name) -- color names: ak.colors.txt
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

setup()
