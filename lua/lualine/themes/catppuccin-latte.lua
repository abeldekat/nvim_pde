local theme = require("catppuccin.utils.lualine")("latte")
local transformed = require("ak.misc.lualine").transform(theme)
return transformed
