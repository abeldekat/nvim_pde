local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("catppuccin*", {
  name = "catppuccin",
  flavours = { "catppuccin-frappe", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte" },
})

local opts = {
  flavour = prefer_light and "latte" or "mocha",
  custom_highlights = function(c)
    return { -- left and right, dynamic
      -- MiniStatuslineFilename is a bit to dark:
      MiniStatuslineFilename = { fg = c.subtext1, bg = c.mantle },
      MiniStatuslineModeNormal = { link = "MiniStatuslineFilename" },

      MiniJump2dSpot = { bg = c.base, fg = c.flamingo, style = { "bold", "underline" } },
      MiniJump2dSpotAhead = { bg = c.base, fg = c.flamingo, style = { "bold", "underline" } },

      MiniPickMatchRanges = { fg = c.peach, style = { "bold" } },
      MiniPickNormal = { link = "Normal" }, -- DiagnosticFloatingHint

      MsgArea = { fg = c.overlay0 }, -- Area for messages and cmdline
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
    headlines = true,
    illuminate = { enabled = false },
    indent_blankline = { enabled = true },
    leap = false,
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
