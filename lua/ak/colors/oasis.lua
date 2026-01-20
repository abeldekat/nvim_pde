local prefer_light = require('ak.color').prefer_light

local variants = {
  'oasis-abyss', -- black
  'oasis-cactus', -- green
  'oasis-canyon', -- orange
  'oasis-desert', -- grey
  'oasis-dune', -- yellow
  'oasis-lagoon', -- blue, the default
  'oasis-midnight', -- off black
  'oasis-mirage', -- teal
  'oasis-night', -- night sky
  'oasis-rose', -- pink
  'oasis-sol', -- red
  'oasis-starlight', -- black vivid
  'oasis-twilight', -- purple
}
local info = { name = 'oasis', variants = variants }
_G.Config.add_theme_info('oasis*', info, 'Oasis variants')

vim.o.background = prefer_light and 'light' or 'dark'
local opts = {
  style = 'desert',
  -- styles = {
  --   bold = true, -- Enable bold text (keywords, functions, etc.)
  --   italic = true, -- Enable italics (comments, certain keywords)
  --   underline = true, -- Enable underlined text (matching words)
  --   undercurl = true, -- Enable undercurl for diagnostics/spelling
  --   strikethrough = true, -- Enable strikethrough text (deprecations)
  -- },
  integrations = {
    default_enabled = false, -- Default behavior: true = enable all, false = disable all
    plugins = { -- See theme_generator create_plugin_highlights, opt-in behaviour
      mini_clue = true,
      mini_cmdline = true,
      mini_completion = true,
      mini_diff = true,
      mini_files = true,
      mini_icons = true,
      mini_jump = true,
      mini_map = true,
      mini_pick = true,
      mini_starter = true,
      mini_statusline = true,
      mini_tabline = true,
      mini_trailspace = true,
    },
  },
}
require('oasis').setup(opts)
