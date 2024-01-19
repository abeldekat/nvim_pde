local prefer_light = require("ak.color").prefer_light

-- forked from tokyonight
vim.o.background = prefer_light and "light" or "dark"
