local theme = require("catppuccin.utils.lualine")("mocha")
local transformed = require("misc.lualine").transform(theme)
return transformed
