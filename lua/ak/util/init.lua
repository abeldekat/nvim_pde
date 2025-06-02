---@class ak.util
---@field color ak.util.color
---@field color_lazygit ak.util.color_lazygit
---@field defer ak.util.defer
---@field deps ak.util.deps
---@field lazyrc ak.util.lazyrc
---@field pick ak.util.pick
---@field toggle ak.util.toggle
local M = {}

-- Start shared variables, overridden in ak.deps.coding and used in ak.config:

---@type boolean for the integration of treesitter textobjects and mini.ai
M.use_mini_ai = false

---@type "blink" | "mini" | "none"
M.completion = "none"

---@type "blink" | "native"
M.mini_completion_fuzzy_provider = "native"

-- End shared variables

setmetatable(M, {
  __index = function(t, k)
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("ak.util." .. k)
    return t[k]
  end,
})

M.full_path_of_current_buffer = function()
  return vim.fn.expand("%:p") -- /home/user....
end

return M
