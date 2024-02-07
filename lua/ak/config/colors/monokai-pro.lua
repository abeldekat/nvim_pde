--          ╭─────────────────────────────────────────────────────────╮
--          │      monokai-pro does not support mini.statusline       │
--          ╰─────────────────────────────────────────────────────────╯

local Utils = require("ak.util")

Utils.color.add_toggle("monokai-pro*", {
  name = "monokai-pro",
  -- "monokai-pro-default", "monokai-pro-ristretto", "monokai-pro-spectrum",
  flavours = { "monokai-pro-octagon", "monokai-pro-machine", "monokai-pro-classic" },
})

require("monokai-pro").setup({
  filter = "octagon",
  override = function(c)
    -- bg = c.statusBar.background, modified:
    local lualine = { bg = c.base.dimmed5, fg = c.statusBar.activeForeground }
    return {
      -- Also possible: Copy the values of the sonokai theme
      MiniStatuslineModeNormal = lualine, -- left and right, dynamic
      MiniStatuslineDevinfo = lualine,
    }
  end,
})
