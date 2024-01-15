local Utils = require("ak.misc.colorutils")
local prefer_light = require("ak.misc.color").prefer_light
local opts = {
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
Utils.add_toggle("catppuccin*", {
  name = "catppuccin",
  flavours = { "catppuccin-frappe", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte" },
})
opts.flavour = prefer_light and "latte" or "frappe"
require("catppuccin").setup(opts)
