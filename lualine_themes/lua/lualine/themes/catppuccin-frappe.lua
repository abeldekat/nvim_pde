local theme = require("catppuccin.utils.lualine")("frappe")
local transformed = require("ak.lualine").transform(theme)
return transformed
