local prefer_light = require('ak.color').prefer_light

local info = {
  name = 'catppuccin',
  variants = { 'catppuccin-frappe', 'catppuccin-mocha', 'catppuccin-macchiato', 'catppuccin-latte' },
}
_G.Config.add_theme_info('catppuccin*', info, 'Catppuccin variants')

local opts = {
  flavour = prefer_light and 'latte' or 'frappe',
  custom_highlights = function(c)
    return { -- left and right, dynamic
      MiniStatuslineFilename = { fg = c.subtext1, bg = c.mantle },

      MiniJump2dSpot = { fg = c.orange, style = { 'bold', 'nocombine' } },
      MiniJump2dSpotAhead = { link = 'MiniJump2dSpot' },
      MiniJump2dSpotUnique = { link = 'MiniJump2dSpot' },
      MiniPickMatchRanges = { fg = c.peach, style = { 'bold' } },
      MiniPickNormal = { link = 'Normal' }, -- DiagnosticFloatingHint

      MsgArea = { fg = c.overlay0 }, -- Area for messages and cmdline
    }
  end,
  lsp_styles = { -- must copy...
    virtual_text = {
      errors = { 'italic' },
      hints = { 'italic' },
      warnings = { 'italic' },
      information = { 'italic' },
      ok = { 'italic' },
    },
    underlines = {
      errors = { 'undercurl' },
      hints = { 'undercurl' },
      warnings = { 'undercurl' },
      information = { 'undercurl' },
      ok = { 'underline' },
    },
    inlay_hints = { background = true },
  },
  default_integrations = false,
  integrations = {
    markdown = true,
    mini = {
      enabled = true,
      indentscope_color = 'text',
    },
    render_markdown = true,
    semantic_tokens = true,
    treesitter_context = true,
  },
}

require('catppuccin').setup(opts)
