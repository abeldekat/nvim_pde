local theme = require("catppuccin.utils.lualine")("frappe")
local transformed = require("misc.lualine").transform(theme)
return transformed
