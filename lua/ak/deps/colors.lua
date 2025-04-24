local Util = require("ak.util")
local Color = require("ak.color")
local MiniDeps = require("mini.deps")
local Picker = Util.pick
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

local colors = {
  one = function()
    return {
      { source = "catppuccin/nvim", name = "colors_catppuccin" },
      { source = "EdenEast/nightfox.nvim", name = "colors_nightfox" },
      { source = "ribru17/bamboo.nvim", name = "colors_bamboo" },
      { source = "savq/melange-nvim", name = "colors_melange" },
      { source = "sainnhe/sonokai", name = "colors_sonokai" },
      { source = "sainnhe/everforest", name = "colors_everforest" },
      { source = "sainnhe/gruvbox-material", name = "colors_gruvbox-material" },
      { source = "folke/tokyonight.nvim", name = "colors_tokyonight" },
      { source = "rose-pine/neovim", name = "colors_rose-pine" },
    }
  end,

  two = function()
    return {
      --     { source = "navarasu/onedark.nvim", name = "colors_onedark" },
      --     { source = "rebelot/kanagawa.nvim", name = "colors_kanagawa" },
      --     { source = "sainnhe/edge", name = "colors_edge" },
      --     { source = "craftzdog/solarized-osaka.nvim", name = "colors_solarized-osaka" },
      --     { source = "ellisonleao/gruvbox.nvim", name = "colors_gruvbox" },
      --     { source = "Shatur/neovim-ayu", name = "colors_ayu" },
      --     { source = "lifepillar/vim-solarized8", name = "colors_solarized8", checkout = "neovim" },
      --     { source = "ronisbr/nano-theme.nvim", name = "colors_nano-theme" },
    }
  end,
}

local function filter_specs_to_use(groups)
  local result = {}
  for _, group in ipairs(groups) do
    for _, spec in ipairs(group()) do
      result[spec.name] = spec
    end
  end
  return result
end

local colors_loaded = false
local function add_keymap_all_colors(specs_to_use)
  vim.keymap.set("n", "<leader>foc", function()
    if not colors_loaded then
      for _, spec in pairs(specs_to_use) do -- Load all specs and their configs
        add(spec)
        require(Util.color.to_config_name(spec.name))
      end
      require(Util.color.from_color_name("mini").config_name) -- Mini collection
      colors_loaded = true
    end

    vim.schedule(function() Picker.colors() end)
  end, { desc = "Colorscheme picker", silent = true })
end

local function activate(color_name, config_name)
  Util.try(function()
    require(config_name)
    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg) Util.error(msg) end,
  })
end

local color_name = Color.color
local color_info = Util.color.from_color_name(color_name)
local specs = filter_specs_to_use({ -- key: spec_name, value: spec
  colors.one,
  colors.two,
})

now(function()
  add_keymap_all_colors(specs)
  if color_info.spec_name then add(specs[color_info.spec_name]) end
  activate(color_name, color_info.config_name)
end)

later(function()
  -- stylua: ignore
  for _, spec in pairs(specs) do register(spec) end
end)
