local Util = require("ak.util")

require("eyeliner").setup({
  highlight_on_key = true, -- show highlights only after keypress
  dim = true, -- dim all other characters if set to true (recommended!)
})
Util.register_referenced("eyeliner.nvim")
