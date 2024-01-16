--          ╭─────────────────────────────────────────────────────────╮
--          │   Number of themes: 12 + 2(tokyonight and catppuccin)   │
--          │                                                         │
--          │                   Best light themes:                    │
--          │                       tokyonight                        │
--          │       catppuccin(latte is similar to tokyonight)        │
--          │                       solarized8                        │
--          │                    gruvbox-material                     │
--          │                    nightfox dawnfox                     │
--          │                         gruvbox                         │
--          │                         bamboo                          │
--          │                          nano                           │
--          │                       onedarkpro                        │
--          │                       astrotheme                        │
--          │                        rose-pine                        │
--          │                         onedark                         │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.misc.colorutils")

local result = {}

local function one()
  return {
    {
      "folke/tokyonight.nvim",
      name = "colors_tokyonight",
      config = function()
        require("ak.config.colors.tokyonight")
      end,
    },
    {
      "catppuccin/nvim",
      name = "colors_catppuccin",
      config = function()
        require("ak.config.colors.catppuccin")
      end,
    },
    {
      "EdenEast/nightfox.nvim",
      name = "colors_nightfox",
      config = function()
        require("ak.config.colors.nightfox")
      end,
    },
    {
      "rose-pine/neovim",
      name = "colors_rose-pine",
      config = function()
        require("ak.config.colors.rose_pine")
      end,
    },
  }
end

local function two()
  return {
    {
      "navarasu/onedark.nvim",
      name = "colors_onedark",
      config = function()
        require("ak.config.colors.onedark")
      end,
    },
    {
      "ellisonleao/gruvbox.nvim",
      name = "colors_gruvbox",
      config = function()
        require("ak.config.colors.gruvbox")
      end,
    },
    {
      "lifepillar/vim-solarized8",
      name = "colors_solarized8",
      branch = "neovim",
      config = function()
        require("ak.config.colors.solarized8_flat")
      end,
    },
    {
      "craftzdog/solarized-osaka.nvim",
      name = "colors_solarized-osaka",
      config = function()
        require("ak.config.colors.solarized_osaka")
      end,
    },
    {
      "ronisbr/nano-theme.nvim",
      name = "colors_nano",
      config = function()
        require("ak.config.colors.nano_theme")
      end,
    },
  }
end

local function three()
  return {
    {
      "sainnhe/sonokai",
      name = "colors_sonokai",
      config = function()
        require("ak.config.colors.sonokai")
      end,
    },
    {
      "loctvl842/monokai-pro.nvim",
      name = "colors_monokai",
      config = function()
        require("ak.config.colors.monokai_pro")
      end,
    },
    {
      "sainnhe/everforest",
      name = "colors_everforest",
      config = function()
        require("ak.config.colors.everforest")
      end,
    },
    {
      "sainnhe/gruvbox-material",
      name = "colors_gruvbox-material",
      config = function()
        require("ak.config.colors.gruvbox_material")
      end,
    },
    {
      "ribru17/bamboo.nvim",
      name = "colors_bamboo",
      config = function()
        require("ak.config.colors.bamboo")
      end,
    },
    {
      "savq/melange-nvim",
      name = "colors_melange",
      config = function()
        require("ak.config.colors.melange")
      end,
    },
  }
end

local function four()
  return {
    {
      "rebelot/kanagawa.nvim",
      name = "colors_kanagawa",
      config = function()
        require("ak.config.colors.kanagawa")
      end,
    },
    {
      "Shatur/neovim-ayu",
      name = "colors_ayu",
      config = function()
        require("ak.config.colors.ayu")
      end,
    },
    {
      "sainnhe/edge",
      name = "colors_edge",
      config = function()
        require("ak.config.colors.edge")
      end,
    },
    {
      "daschw/leaf.nvim",
      name = "colors_leaf",
      config = function()
        require("ak.config.colors.leaf")
      end,
    },
    {
      "AstroNvim/astrotheme",
      name = "colors_astrotheme",
      config = function()
        require("ak.config.colors.astrotheme")
      end,
    },
  }
end

local groups = {
  one,
  -- two,
  -- three,
  -- four,
}
for _, group in ipairs(groups) do
  result = vim.list_extend(
    result,
    vim.tbl_map(function(color)
      color["keys"] = Utils.keys() -- keys implies lazy loading
      return color
    end, group())
  )
end
return result
