local theme = require("catppuccin.utils.lualine")("frappe")
local transformed = require("ak.misc.lualine").transform(theme)
return transformed
