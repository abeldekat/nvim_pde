local Utils = require("misc.colorutils")
local prefer_light = require("misc.color").prefer_light

if true then
  return {}
end

return {
  { -- good gruvbox-like light theme
    "rebelot/kanagawa.nvim", -- light is lotus, dark is wave
    name = "colors_kanagawa",
    main = "kanagawa",
    keys = Utils.keys(),
    opts = function()
      Utils.add_toggle("kanagawa*", {
        name = "kanagawa",
        flavours = { "kanagawa-wave", "kanagawa-dragon", "kanagawa-lotus" },
      })
      vim.o.background = prefer_light and "light" or "dark"
      -- stylua: ignore
      return prefer_light and {
        overrides = function(colors)
          return { -- Improve FlashLabel:
            -- Substitute = { fg = theme.ui.fg, bg = theme.vcs.removed },
            Substitute = { fg = colors.theme.ui.fg_reverse, bg = colors.theme.vcs.removed },
          }
        end,
      } or {}
    end,
  },

  { -- unique colors, light is vague
    "Shatur/neovim-ayu",
    name = "colors_ayu",
    main = "ayu",
    keys = Utils.keys(),
    opts = function()
      Utils.add_toggle("ayu*", {
        name = "ayu",
        flavours = { "ayu-mirage", "ayu-dark", "ayu-light" },
      })
      vim.o.background = prefer_light and "light" or "dark"
      return { mirage = true, overrides = {} }
    end,
  },

  {
    "sainnhe/edge",
    name = "colors_edge",
    main = "edge",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("edge", {
        name = "edge",
        -- stylua: ignore
        flavours = {
          { "dark", "default" }, { "dark", "aura" }, { "dark", "neon" },
          { "light", "default" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          vim.g.edge_style = flavour[2]
          vim.cmd.colorscheme("edge")
        end,
      })
      vim.g.edge_better_performance = 1
      vim.g.edge_enable_italic = 1
      vim.o.background = prefer_light and "light" or "dark"
      vim.g.edge_style = "default"
    end,
  },

  { -- based on Leaf KDE Plasma Theme
    "daschw/leaf.nvim",
    name = "colors_leaf",
    main = "leaf",
    keys = Utils.keys(),
    opts = function()
      Utils.add_toggle("leaf", {
        name = "leaf",
        -- stylua: ignore
        flavours = {
          { "dark", "low" }, { "dark", "medium" }, { "dark", "high" },
          { "light", "low" }, { "light", "medium" }, { "light", "high" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          require("leaf").setup({ contrast = flavour[2] })
          vim.cmd.colorscheme("leaf")
        end,
      })
      vim.o.background = prefer_light and "light" or "dark"
      return { contrast = "medium" }
    end,
  },

  {
    "AstroNvim/astrotheme",
    name = "colors_astrotheme",
    main = "astrotheme",
    keys = Utils.keys(),
    opts = function()
      Utils.add_toggle("astro*", {
        name = "astrotheme",
        flavours = { "astrodark", "astromars", "astrolight" },
      })
      vim.o.background = prefer_light and "light" or "dark"
      return {
        palette = prefer_light and "astrolight" or "astrodark",
      }
    end,
  },
}
