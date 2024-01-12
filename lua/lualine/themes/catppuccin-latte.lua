local theme = require("catppuccin.utils.lualine")("latte")
local transformed = require("misc.lualine").transform(theme)
return transformed
