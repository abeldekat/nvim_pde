--          ╭─────────────────────────────────────────────────────────╮
--          │           catppuccin supports mini.statusline           │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")
local prefer_light = require("ak.color").prefer_light

Utils.color.add_toggle("catppuccin*", {
  name = "catppuccin",
  flavours = { "catppuccin-frappe", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte" },
})

local opts = {
  flavour = prefer_light and "latte" or "frappe",
  custom_highlights = function()
    -- see catppuccin.utils.lualine
    local C = require("catppuccin.palettes").get_palette()
    local O = require("catppuccin").options
    local transparent_bg = O.transparent_background and "NONE" or C.mantle

    local normal_lualine_c = { bg = transparent_bg, fg = C.text }
    return {
      MiniStatuslineModeNormal = normal_lualine_c, -- left and right, dynamic
      MiniStatuslineDevinfo = normal_lualine_c, -- all inner groups
    }
  end,
  integrations = {
    aerial = true,
    alpha = false,
    cmp = true,
    dashboard = true,
    flash = true,
    gitsigns = true,
    headlines = true,
    illuminate = true,
    indent_blankline = { enabled = true },
    leap = false,
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
    neotest = true,
    neotree = false,
    noice = false,
    notify = false,
    semantic_tokens = true,
    telescope = true,
    treesitter = true,
    treesitter_context = true,
    which_key = true,
    --
    nvimtree = false,
    harpoon = true,
    dropbar = { enabled = false },
  },
}

require("catppuccin").setup(opts)
