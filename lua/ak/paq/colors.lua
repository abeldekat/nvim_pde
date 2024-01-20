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
      as = "colors_nano",
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
      as = "colors_monokai",
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
  -- two,
  -- three,
  -- four,
}

function M.spec()
  local result = {}

  for _, group in ipairs(groups) do
    result = vim.list_extend(
      result,
      vim.tbl_map(function(color)
        color["opt"] = true
        return color
      end, group())
    )
  end

  Util.paq.on_keys(function()
    local function load_all()
      for _, color in ipairs(result) do
        vim.cmd.packadd(color.as)
        require("ak.config.colors." .. color.as:gsub("colors_", ""))
      end
    end

    -- Prevent <leader>uu keys to show up as input inside telescope:
    vim.keymap.set("n", "<leader>uu", function() end, { desc = "No-op all colors", silent = true })
    vim.schedule(function()
      local keys = Util.color.keys()
      load_all()
      -- execute the function inside the only item of the list:
      keys[1][2]()
    end)
  end, "<leader>uu", "Load all colors")

  return result
end

function M.setup()
  -- Dummy, the colorscheme is handled in start
end

return M
