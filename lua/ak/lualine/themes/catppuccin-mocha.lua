local theme = require("catppuccin.utils.lualine")("mocha")
local transformed = require("ak.misc.lualine").transform(theme)
return transformed
