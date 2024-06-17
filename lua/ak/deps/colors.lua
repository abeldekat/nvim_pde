--          ╭─────────────────────────────────────────────────────────╮
--          │                    colors mini.nvim:                    │
--          │   - `randomhue` - random background and foreground of   │
--          │          the same hue with medium saturation.           │
--          │  - `minicyan` - cyan and grey main colors with medium   │
--          │            contrast and saturation palette.             │
--          │ - `minischeme` - blue and yellow main colors with high  │
--          │            contrast and saturation palette.             │
--          ╰─────────────────────────────────────────────────────────╯

local M = {}
local Util = require("ak.util")
local Color = require("ak.color")
local MiniDeps = require("mini.deps")
local Picker = Util.pick
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

-- Contains example "gruvbuddy":
-- local spec_colorbuddy = { source = "tjdevries/colorbuddy.nvim", name = "colors_gruvbuddy" }

local function hook_base46()
  vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"
  vim.cmd.packadd("colors_base46")
  require("ak.config.colors.base46").compile()
end
local spec_base46 = {
  -- Dark: bearded_arc chadraculu doomchad everblush falcon flexoki github_dark
  -- material-darker melange monekai sweetpastel solarized_dark osaka
  -- tomorrow_night wombat
  -- Light: flex-light flexoki-light github_light material-lighter nano-light
  source = "nvchad/base46", -- v2.5 is the default
  name = "colors_base46",
  hooks = { post_install = hook_base46, post_checkout = hook_base46 },
}

local colors = {
  one = function()
    return {
      { source = "catppuccin/nvim", name = "colors_catppuccin" },
      { source = "folke/tokyonight.nvim", name = "colors_tokyonight" },
      { source = "EdenEast/nightfox.nvim", name = "colors_nightfox" },
      { source = "rose-pine/neovim", name = "colors_rose-pine" },
    }
  end,

  two = function()
    return {
      { source = "sainnhe/sonokai", name = "colors_sonokai" },
      { source = "ribru17/bamboo.nvim", name = "colors_bamboo" },
      { source = "sainnhe/everforest", name = "colors_everforest" },
      { source = "sainnhe/gruvbox-material", name = "colors_gruvbox-material" },
      { source = "sainnhe/edge", name = "colors_edge" },
    }
  end,

  three = function()
    return {
      { source = "rebelot/kanagawa.nvim", name = "colors_kanagawa" },
      { source = "ellisonleao/gruvbox.nvim", name = "colors_gruvbox" },
      { source = "Shatur/neovim-ayu", name = "colors_ayu" },
      { source = "navarasu/onedark.nvim", name = "colors_onedark" },
    }
  end,

  four = function()
    return {
      { source = "lifepillar/vim-solarized8", name = "colors_solarized8", checkout = "neovim" },
      { source = "AstroNvim/astrotheme", name = "colors_astrotheme" },
      { source = "ronisbr/nano-theme.nvim", name = "colors_nano-theme" },
    }
  end,
}

local function register_specs(groups)
  local result = {}
  for _, group in ipairs(groups) do
    for _, spec in ipairs(group()) do
      table.insert(result, spec)
    end
  end
  later(function()
    for _, spec in ipairs(result) do
      register(spec)
    end
  end)
  return result
end

local colors_loaded = false
local function add_picker(specs_to_use)
  vim.keymap.set("n", "<leader>uu", function()
    if not colors_loaded then
      for _, spec in ipairs(specs_to_use) do -- Load all specs and their configs
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

function M.colorscheme()
  local color_name = Color.color
  local color_info = Util.color.from_color_name(color_name)

  add_picker(register_specs({
    colors.one,
    colors.two,
    colors.three,
    colors.four,
  }))

  later(function() register(spec_base46) end)
  if color_name == "base46" then -- collection, special case, no colorscheme command
    now(function()
      require(color_info.config_name).setup(function()
        add(spec_base46) -- only add spec when selecting a new theme.
        return vim.fn.stdpath("data") .. "/site/pack/deps/opt/" .. spec_base46.name .. "/lua/base46/themes"
      end)
    end)
  else
    now(function()
      if color_info.spec_name then add(color_info.spec_name) end
      activate(color_name, color_info.config_name)
    end)
  end
end

return M
