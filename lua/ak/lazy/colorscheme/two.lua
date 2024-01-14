local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light

-- if true then
--   return {}
-- end

return {

  { -- has its own toggle_style
    "navarasu/onedark.nvim",
    name = "colors_onedark",
    main = "onedark",
    keys = Utils.keys(),
    config = function()
      require("onedark").setup({ -- the default is dark
        toggle_style_list = { "warm", "warmer", "light", "dark", "darker", "cool", "deep" },
        toggle_style_key = "<leader>a",
        style = "dark", -- ignored on startup, onedark.load must be used.
      })
    end,
  },

  {
    "ellisonleao/gruvbox.nvim",
    name = "colors_gruvbox",
    main = "gruvbox",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("gruvbox", {
        name = "gruvbox",
        -- stylua: ignore
        flavours = {
          { "dark", "soft" }, { "dark", "" }, { "dark", "hard" },
          { "light", "soft" }, { "light", "" }, { "light", "hard" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          require("gruvbox").setup({ contrast = flavour[2] })
          vim.cmd.colorscheme("gruvbox")
        end,
      })
      vim.o.background = prefer_light and "light" or "dark"
      require("gruvbox").setup({ contrast = "soft", italic = { strings = false } })
    end,
  },

  {
    "lifepillar/vim-solarized8",
    name = "colors_solarized8",
    main = "vim-solarized8",
    branch = "neovim",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("solarized8*", {
        name = "solarized8",
        -- stylua: ignore
        flavours = { -- solarized8_high not used
          { "dark", "solarized8_flat" }, { "dark", "solarized8_low" }, { "dark", "solarized8" },
          { "light", "solarized8_flat" }, { "light", "solarized8_low" }, { "light", "solarized8" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          vim.cmd.colorscheme(flavour[2])
        end,
      })
      vim.o.background = prefer_light and "light" or "dark"
    end,
  },

  { -- forked from tokyonight
    "craftzdog/solarized-osaka.nvim",
    name = "colors_solarized-osaka",
    main = "solarized-osaka",
    keys = Utils.keys(),
    config = function()
      vim.o.background = prefer_light and "light" or "dark"
    end,
  },

  { -- very few colors, solarized look
    "ronisbr/nano-theme.nvim",
    name = "colors_nano",
    main = "nano-theme",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("nano-theme", {
        name = "nano-theme",
        flavours = { "dark", "light" },
        toggle = function(flavour)
          vim.o.background = flavour
          vim.cmd.colorscheme("nano-theme")
        end,
      })
      vim.o.background = prefer_light and "light" or "dark"
    end,
  },
}
