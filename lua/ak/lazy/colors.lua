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
  --
end

local function three()
  --
end

local function three()
  --
end

local use = {
  one,
  -- two,
  -- three,
  -- four,
}
for _, group in ipairs(use) do
  result = vim.list_extend(
    result,
    vim.tbl_map(function(color)
      color["keys"] = Utils.keys() -- keys implies lazy
      return color
    end, group())
  )
end
return result
