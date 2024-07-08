local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("catppuccin*", {
  name = "catppuccin",
  flavours = { "catppuccin-frappe", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte" },
})

local opts = {
  flavour = prefer_light and "latte" or "frappe",
  custom_highlights = function(colors)
    return { -- left and right, dynamic
      MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" },

      MiniHipatternsFixme = { fg = colors.base, bg = colors.red, style = { "bold" } },
      MiniHipatternsHack = { fg = colors.base, bg = colors.yellow, style = { "bold" } },
      MiniHipatternsNote = { fg = colors.base, bg = colors.teal, style = { "bold" } },
      MiniHipatternsTodo = { fg = colors.base, bg = colors.sky, style = { "bold" } },

      MsgArea = { fg = colors.overlay0 }, -- Area for messages and cmdline
    }
  end,
  integrations = {
    aerial = true,
    alpha = false,
    cmp = true,
    dashboard = false,
    dropbar = { enabled = false },
    fidget = true,
    flash = false,
    gitsigns = false,
    harpoon = true,
    headlines = true,
    illuminate = { enabled = false },
    indent_blankline = { enabled = true },
    leap = true,
    lsp_trouble = false,
    mason = true,
    markdown = true,
    mini = true, -- enabled by default
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
    navic = { enabled = false },
    neogit = false,
    neotest = true,
    neotree = false,
    noice = false,
    notify = false,
    nvimtree = false,
    rainbow_delimiters = false,
    semantic_tokens = true,
    telescope = false,
    treesitter = true,
    treesitter_context = true,
    ufo = false,
    which_key = false,
  },
}

require("catppuccin").setup(opts)
