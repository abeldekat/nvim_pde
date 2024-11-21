-- TESTING: Base16
local prefer_light = require("ak.color").prefer_light
vim.o.background = prefer_light and "light" or "dark"
