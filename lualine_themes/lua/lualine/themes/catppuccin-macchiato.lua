local theme = require("catppuccin.utils.lualine")("macchiato")
local transformed = require("ak.lualine").transform(theme)
return transformed
