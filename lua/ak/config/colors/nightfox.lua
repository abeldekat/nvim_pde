--nightfox has themes, no flavour options...
local Utils = require("ak.util")

Utils.color.add_toggle("*fox", {
  name = "nightfox",
  -- "carbonfox", "dayfox",
  flavours = { "nordfox", "nightfox", "duskfox", "terafox", "dawnfox" },
})

local opts = {
  dim_inactive = true,
}

local function groups()
  local function per_style(style)
    local s = require("nightfox.spec").load(style)
    local normal_lualine_c = { bg = s.bg0, fg = s.fg2 }
    return {
      MiniStatuslineModeNormal = normal_lualine_c, -- left and right, dynamic
      MiniStatuslineDevinfo = normal_lualine_c, -- all inner groups
    }
  end
  return {
    nordfox = per_style("nordfox"),
    nightfox = per_style("nightfox"),
    duskfox = per_style("duskfox"),
    terafox = per_style("terafox"),
    dawnfox = per_style("dawnfox"),
  }
end

require("nightfox").setup({ options = opts, groups = groups() })
