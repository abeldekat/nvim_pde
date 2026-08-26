vim.o.background = require('ak.color').prefer_light and 'light' or 'dark'

local name = 'thorn'
Config.add_theme_info(name, { name = name, variants = { name } }, 'Thorn dummy variants')

-- Restrict the number of supported plugins
require('thorn.groups').plugins = { mini = true }
require('thorn').setup({
  styles = { diagnostic = { error = { highlight = false } } },
})
