local prefer_light = require('ak.color').prefer_light
vim.o.background = prefer_light and 'light' or 'dark'
local name = 'thorn'

Config.add_theme_info(name, { name = name, variants = { name } }, 'Thorn dummy variants')
require('thorn').setup()
