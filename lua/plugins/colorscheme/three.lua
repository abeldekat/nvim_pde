local Utils = require("misc.colorutils")
local prefer_light = require("misc.color").prefer_light

-- if true then
--   return {}
-- end

return {
  { -- monokai variations
    "sainnhe/sonokai",
    name = "colors_sonokai",
    main = "sonokai",
    keys = Utils.keys(),
    config = function()
      -- shusia, maia and espresso variants are modified versions of Monokai Pro
      Utils.add_toggle("sonokai", {
        name = "sonokai",
        flavours = { "andromeda", "espresso", "atlantis", "shusia", "maia", "default" },
        toggle = function(flavour)
          vim.g.sonokai_style = flavour
          vim.cmd.colorscheme("sonokai")
        end,
      })
      vim.g.sonokai_better_performance = 1
      vim.g.sonokai_enable_italic = 1
      vim.g.sonokai_disable_italic_comment = 1
      vim.g.sonokai_dim_inactive_windows = 1
      vim.g.sonokai_style = "andromeda"
    end,
  },

  {
    "loctvl842/monokai-pro.nvim",
    name = "colors_monokai",
    main = "monokai-pro",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("monokai-pro*", {
        name = "monokai-pro",
        -- "monokai-pro-default", "monokai-pro-ristretto", "monokai-pro-spectrum",
        flavours = { "monokai-pro-octagon", "monokai-pro-machine", "monokai-pro-classic" },
      })
      require("monokai-pro").setup({
        filter = "octagon",
      })
    end,
  },

  { -- lazygit colors are not always readable,  good light theme
    "sainnhe/everforest",
    name = "colors_everforest",
    main = "everforest",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("everforest", {
        name = "everforest",
        -- stylua: ignore
        flavours = {
          { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
          { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          vim.g.everforest_background = flavour[2]
          vim.cmd.colorscheme("everforest")
        end,
      })
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.o.background = prefer_light and "light" or "dark"
      vim.g.everforest_background = "medium"
    end,
  },

  {
    "sainnhe/gruvbox-material",
    name = "colors_gruvbox-material",
    main = "gruvbox-material",
    keys = Utils.keys(),
    config = function()
      local name = "gruvbox-material"
      Utils.add_toggle("*material", {
        name = name,
        -- stylua: ignore
        flavours = {
          { "dark", "soft" }, { "dark", "medium" }, { "dark", "hard" },
          { "light", "soft" }, { "light", "medium" }, { "light", "hard" },
        },
        toggle = function(flavour)
          vim.o.background = flavour[1]
          vim.g.gruvbox_material_background = flavour[2]
          vim.cmd.colorscheme(name)
        end,
      })
      vim.g.gruvbox_material_foreground = "material" -- "mix", "original"
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_background = "soft"
      vim.g.gruvbox_material_foreground = "material"
      vim.o.background = prefer_light and "light" or "dark"
    end,
  },

  {
    "ribru17/bamboo.nvim",
    name = "colors_bamboo",
    main = "bamboo",
    keys = Utils.keys(),
    config = function() -- regular vulgaris greener multiplex light mode
      vim.o.background = prefer_light and "light" or "dark"
      require("bamboo").setup({
        style = "vulgaris",
        toggle_style_key = "<leader>a",
        dim_inactive = true,
      })
    end,
  },

  {
    "savq/melange-nvim",
    name = "colors_melange",
    main = "melange",
    keys = Utils.keys(),
    config = function()
      Utils.add_toggle("melange", {
        name = "melange",
        flavours = { "dark", "light" },
        toggle = function(flavour)
          vim.o.background = flavour
          vim.cmd.colorscheme("melange")
        end,
      })
      vim.o.background = prefer_light and "light" or "dark"
    end,
  },
}
