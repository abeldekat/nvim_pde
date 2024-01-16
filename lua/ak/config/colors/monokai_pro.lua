local Utils = require("ak.misc.colorutils")

Utils.add_toggle("monokai-pro*", {
  name = "monokai-pro",
  -- "monokai-pro-default", "monokai-pro-ristretto", "monokai-pro-spectrum",
  flavours = { "monokai-pro-octagon", "monokai-pro-machine", "monokai-pro-classic" },
})
require("monokai-pro").setup({
  filter = "octagon",
})
