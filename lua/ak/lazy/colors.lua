local Util = require("ak.util")
local result = {}

local function one()
  return {
    {
      "folke/tokyonight.nvim",
      name = "colors_tokyonight",
      config = function() require("ak.config.colors.tokyonight") end,
    },
    {
      "catppuccin/nvim",
      name = "colors_catppuccin",
      config = function() require("ak.config.colors.catppuccin") end,
    },
    {
      "EdenEast/nightfox.nvim",
      name = "colors_nightfox",
      config = function() require("ak.config.colors.nightfox") end,
    },
    {
      "rose-pine/neovim",
      name = "colors_rose-pine",
      config = function() require("ak.config.colors.rose-pine") end,
    },
  }
end

local function two()
  return {
    {
      "navarasu/onedark.nvim",
      name = "colors_onedark",
      config = function() require("ak.config.colors.onedark") end,
    },
    {
      "sainnhe/gruvbox-material",
      name = "colors_gruvbox-material",
      config = function() require("ak.config.colors.gruvbox-material") end,
    },
    {
      "sainnhe/sonokai",
      name = "colors_sonokai",
      config = function() require("ak.config.colors.sonokai") end,
    },
    {
      "craftzdog/solarized-osaka.nvim",
      name = "colors_solarized-osaka",
      config = function() require("ak.config.colors.solarized-osaka") end,
    },
    {
      "ronisbr/nano-theme.nvim",
      name = "colors_nano-theme",
      config = function() require("ak.config.colors.nano-theme") end,
    },
  }
end

local function three()
  return {
    {
      "sainnhe/everforest",
      name = "colors_everforest",
      config = function() require("ak.config.colors.everforest") end,
    },
    {
      "ellisonleao/gruvbox.nvim",
      name = "colors_gruvbox",
      config = function() require("ak.config.colors.gruvbox") end,
    },
    {
      "lifepillar/vim-solarized8",
      name = "colors_solarized8",
      branch = "neovim",
      config = function() require("ak.config.colors.solarized8") end,
    },
    {
      "ribru17/bamboo.nvim",
      name = "colors_bamboo",
      config = function() require("ak.config.colors.bamboo") end,
    },
  }
end

local function four()
  return {
    {
      "rebelot/kanagawa.nvim",
      name = "colors_kanagawa",
      config = function() require("ak.config.colors.kanagawa") end,
    },
    {
      "sainnhe/edge",
      name = "colors_edge",
      config = function() require("ak.config.colors.edge") end,
    },
    {
      "Shatur/neovim-ayu",
      name = "colors_ayu",
      config = function() require("ak.config.colors.ayu") end,
    },
    {
      "AstroNvim/astrotheme",
      name = "colors_astrotheme",
      config = function() require("ak.config.colors.astrotheme") end,
    },
  }
end

local groups = {
  one,
  two,
  three,
  four,
}

for _, group in ipairs(groups) do -- Filter selected colors
  result = vim.list_extend(result, group())
end

vim.keymap.set("n", "<leader>uu", function() -- Show all custom colors in telescope
  for _, color_spec in ipairs(result) do
    vim.cmd("Lazy load " .. color_spec.name)
  end

  vim.schedule(function() Util.color.telescope_custom_colors() end)
end, { desc = "Telescope custom colors", silent = true })

return result
