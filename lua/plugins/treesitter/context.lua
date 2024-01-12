local Util = require("util")
local enabled = true

return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",
  keys = {
    {
      "<leader>ut",
      function()
        local tsc = require("treesitter-context")
        tsc.toggle()
        enabled = not enabled
        if enabled then
          Util.info("Enabled treesitter context", { title = "Option" })
        else
          Util.warn("Disabled treesitter tontext", { title = "Option" })
        end
      end,
      desc = "Toggle treesitter context",
    },
  },
  config = function()
    require("treesitter-context").setup({ mode = "cursor", max_lines = 3 })
  end,
}
