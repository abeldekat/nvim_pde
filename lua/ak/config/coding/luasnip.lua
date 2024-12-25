-- Native snippets plugin, maybe usable for mini.snippets?

-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps

local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

-- Adds default user snippets location:
-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })

luasnip.config.setup({
  history = true,
  delete_check_events = "TextChanged",
})
