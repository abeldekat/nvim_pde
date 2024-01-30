--          ╭─────────────────────────────────────────────────────────╮
--          │            Contains plugins that modify code            │
--          ╰─────────────────────────────────────────────────────────╯

-- PERFORMANCE: When later() or verylazy can be used,
-- thus loading async,
-- loading on insertenter does not improve performance.

-- local Util = require("ak.util")
local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

-- Lazy loading benefit: +-5 ms
-- After/plugin is not loaded when using deferring with later():
later(function()
  add("cmp-nvim-lsp")
  -- after.plugin.cmp_nvim_lsp.lua
  -- cmp_nvim_lsp must be present before nvim-lspconfig is added
  -- does not require nvim-cmp but creates an autocmd on insertenter:
  require("cmp_nvim_lsp").setup() -- insertenter
end)
later(function()
  add("nvim-cmp")
  add("cmp_luasnip")
  add("cmp-buffer")
  add("cmp-path")
end)
later(function() -- only needed when using later()):
  -- after.plugin.cmp_luasnip.lua:
  require("cmp").register_source("luasnip", require("cmp_luasnip").new())
  local cmp_luasnip = vim.api.nvim_create_augroup("cmp_luasnip", {})
  vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipCleanup",
    callback = function()
      require("cmp_luasnip").clear_cache()
    end,
    group = cmp_luasnip,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "LuasnipSnippetsAdded",
    callback = function()
      require("cmp_luasnip").refresh()
    end,
    group = cmp_luasnip,
  })
  -- after.plugin.cmp_buffer.lua:
  require("cmp").register_source("buffer", require("cmp_buffer"))
  -- after.plugin.cmp_path.lua:
  require("cmp").register_source("path", require("cmp_path").new())
end)
later(function() -- and finally:
  require("ak.config.completion")
end)

later(function()
  add("nvim-autopairs")
  require("ak.config.pairs")

  add("friendly-snippets")
  add("LuaSnip")
  require("ak.config.snip")

  add("nvim-ts-context-commentstring")
  add("Comment.nvim")
  require("ak.config.comment")

  add("dial.nvim")
  require("ak.config.dial")

  add("substitute.nvim")
  require("ak.config.substitute")

  add("nvim-surround")
  require("ak.config.surround")

  -- duplicate tag in helpfile
  -- Util.defer.on_keys(function()
  --     add("comment-box.nvim")
  --     require("ak.config.comment_box")
  -- end, "<leader>bL", "Load comment-box")
end)
