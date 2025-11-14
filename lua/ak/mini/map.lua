-- NOTE: Might introduce lag on very big buffers (10000+ lines)
local map = require("mini.map")
map.setup({
  -- Use Braille dots to encode text
  symbols = { encode = map.gen_encode_symbols.dot("4x2") },
  -- Show built-in search matches, 'mini.diff' hunks, and diagnostic entries
  integrations = {
    map.gen_integration.builtin_search(),
    map.gen_integration.diff(),
    map.gen_integration.diagnostic(),
  },
})

-- Map built-in navigation characters to force map refresh
for _, key in ipairs({ "n", "N", "*", "#" }) do
  local rhs = key
    -- Also open enough folds when jumping to the next match
    .. "zv"
    .. "<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>"
  vim.keymap.set("n", key, rhs)
end
