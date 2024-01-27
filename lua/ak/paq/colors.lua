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

local Color = require("ak.color")
local Util = require("ak.util")
local M = {}

local function one()
  return {
    {
      "folke/tokyonight.nvim",
      as = "colors_tokyonight",
    },
    {
      "catppuccin/nvim",
      as = "colors_catppuccin",
    },
    {
      "EdenEast/nightfox.nvim",
      as = "colors_nightfox",
    },
    {
      "rose-pine/neovim",
      as = "colors_rose-pine",
    },
  }
end

local function two()
  return {
    {
      "navarasu/onedark.nvim",
      as = "colors_onedark",
    },
    {
      "ellisonleao/gruvbox.nvim",
      as = "colors_gruvbox",
    },
    {
      "lifepillar/vim-solarized8",
      as = "colors_solarized8",
      branch = "neovim",
    },
    {
      "craftzdog/solarized-osaka.nvim",
      as = "colors_solarized-osaka",
    },
    {
      "ronisbr/nano-theme.nvim",
      as = "colors_nano-theme",
    },
  }
end

local function three()
  return {
    {
      "sainnhe/sonokai",
      as = "colors_sonokai",
    },
    {
      "loctvl842/monokai-pro.nvim",
      as = "colors_monokai-pro",
    },
    {
      "sainnhe/everforest",
      as = "colors_everforest",
    },
    {
      "sainnhe/gruvbox-material",
      as = "colors_gruvbox-material",
    },
    {
      "ribru17/bamboo.nvim",
      as = "colors_bamboo",
    },
    {
      "savq/melange-nvim",
      as = "colors_melange",
    },
  }
end

local function four()
  return {
    {
      "rebelot/kanagawa.nvim",
      as = "colors_kanagawa",
    },
    {
      "Shatur/neovim-ayu",
      as = "colors_ayu",
    },
    {
      "sainnhe/edge",
      as = "colors_edge",
    },
    {
      "daschw/leaf.nvim",
      as = "colors_leaf",
    },
    {
      "AstroNvim/astrotheme",
      as = "colors_astrotheme",
    },
  }
end

local groups = {
  one,
  two,
  three,
  four,
}

function M.spec()
  local colors_spec = {}

  for _, group in ipairs(groups) do
    colors_spec = vim.list_extend(
      colors_spec,
      vim.tbl_map(function(color)
        color["opt"] = true
        return color
      end, group())
    )
  end

  vim.keymap.set("n", "<leader>uu", function()
    local from_package_name = Util.color.from_package_name
    for _, color in ipairs(colors_spec) do
      vim.cmd.packadd(color.as)
      require(from_package_name(color.as).config_name)
    end

    vim.schedule(function()
      Util.color.telescope_custom_colors()
    end)
  end, { desc = "Telescope custom colors", silent = true })

  return colors_spec
end

function M.colorscheme()
  Util.try(function()
    local color_name = Color.color
    local info = Util.color.from_color_name(color_name)
    vim.cmd.packadd(info.package_name)
    require(info.config_name)

    vim.cmd.colorscheme(color_name)
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
    end,
  })
end

return M
