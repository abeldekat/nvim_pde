--nightfox has themes, no flavour options...
local Utils = require("ak.misc.colorutils")
Utils.add_toggle("*fox", {
  name = "nightfox",
  -- "carbonfox", "dayfox",
  flavours = { "nordfox", "nightfox", "duskfox", "terafox", "dawnfox" },
})
require("nightfox").setup({ options = { dim_inactive = true } })
