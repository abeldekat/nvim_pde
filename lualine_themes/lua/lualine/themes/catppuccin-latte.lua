local theme = require("catppuccin.utils.lualine")("latte")
local transformed = require("ak.lualine").transform(theme)
return transformed
