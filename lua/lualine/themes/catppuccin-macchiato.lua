local theme = require("catppuccin.utils.lualine")("macchiato")
local transformed = require("misc.lualine").transform(theme)
return transformed
