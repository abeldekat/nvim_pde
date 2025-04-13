--[[
Copied from LazyVim extra
-- ft = { "markdown", "norg", "rmd", "org", "codecompanion" }
--]]
local toggle = function()
  local m = require("render-markdown")
  local enabled = require("render-markdown.state").enabled
  if enabled then
    m.disable()
  else
    m.enable()
  end
  vim.notify("Render markdown: " .. (enabled and "off" or "on"), vim.log.levels.INFO)
end
require("render-markdown").setup({
  code = {
    sign = false,
    width = "block",
    right_pad = 1,
  },
  heading = {
    sign = false,
    icons = {},
  },
  checkbox = {
    enabled = false,
  },
})

vim.keymap.set("n", "<leader>um", toggle, { silent = true, desc = "Toggle render markdown" })
