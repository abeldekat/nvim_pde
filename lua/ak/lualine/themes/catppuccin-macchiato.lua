local theme = require("catppuccin.utils.lualine")("macchiato")
local transformed = require("ak.misc.lualine").transform(theme)
return transformed
