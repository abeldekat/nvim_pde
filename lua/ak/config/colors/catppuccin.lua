--          ╭─────────────────────────────────────────────────────────╮
--          │               mini.statusline: supported                │
--          ╰─────────────────────────────────────────────────────────╯

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

      -- See "DiagnosticError" etc
      MiniHipatternsFixme = { fg = colors.base, bg = colors.red, style = { "bold" } },
      MiniHipatternsHack = { fg = colors.base, bg = colors.yellow, style = { "bold" } },
      MiniHipatternsNote = { fg = colors.base, bg = colors.teal, style = { "bold" } },
      MiniHipatternsTodo = { fg = colors.base, bg = colors.sky, style = { "bold" } },
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
    gitsigns = true,
    harpoon = true,
    headlines = true,
    illuminate = { enabled = false },
    indent_blankline = { enabled = true },
    leap = true,
    lsp_trouble = false,
    mason = true,
    markdown = true,
    mini = true,
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
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    ufo = false,
    which_key = false,
  },
}

require("catppuccin").setup(opts)
