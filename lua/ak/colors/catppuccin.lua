local add_toggle = require("akshared.color_toggle").add
local prefer_light = require("ak.color").prefer_light

add_toggle("catppuccin*", {
  name = "catppuccin",
  flavours = { "catppuccin-frappe", "catppuccin-mocha", "catppuccin-macchiato", "catppuccin-latte" },
})

local opts = {
  flavour = prefer_light and "latte" or "frappe",
  custom_highlights = function(c)
    return { -- left and right, dynamic
      MiniStatuslineFilename = { fg = c.subtext1, bg = c.mantle },

      MiniPickMatchRanges = { fg = c.peach, style = { "bold" } },
      MiniPickNormal = { link = "Normal" }, -- DiagnosticFloatingHint

      MsgArea = { fg = c.overlay0 }, -- Area for messages and cmdline
    }
  end,
  default_integrations = false,
  integrations = {
    blink_cmp = true,
    dap = true,
    dap_ui = true,
    fidget = true,
    leap = true,
    markdown = true,
    mason = true,
    mini = {
      enabled = true,
      indentscope_color = "text",
    },
    native_lsp = { -- must copy...
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
        ok = { "underline" },
      },
      inlay_hints = { background = true },
    },
    neotest = true,
    render_markdown = true,
    semantic_tokens = true,
    treesitter = true,
    treesitter_context = true,
  },
}

require("catppuccin").setup(opts)
