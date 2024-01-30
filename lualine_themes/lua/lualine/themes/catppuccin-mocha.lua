local theme = require("catppuccin.utils.lualine")("mocha")
local transformed = require("ak.lualine").transform(theme)
return transformed
