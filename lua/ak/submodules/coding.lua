--          ╭─────────────────────────────────────────────────────────╮
--          │            Contains plugins that modify code            │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later
local later_only = Util.defer.later_only

-- After/plugin is not loaded when using later(), which uses vim.schedule
-- This function is only needed when lazy-loading nvim-cmp
local function source_after_plugin(after_path)
  vim.cmd.source(vim.fn.stdpath("config") .. "/pack/ak_coding/opt/" .. after_path)
end

-- Lazy loading benefit: +-5 ms
later(function()
  add("cmp-nvim-lsp") -- cmp_nvim_lsp must be present before nvim-lspconfig is added

  add("nvim-cmp")
  add("cmp_luasnip")
  add("cmp-buffer")
  add("cmp-path")
end)
later_only(function()
  -- Plugin does not require nvim-cmp but creates an autocmd on insertenter:
  source_after_plugin("cmp-nvim-lsp/after/plugin/cmp_nvim_lsp.lua")

  -- Plugins requiring nvim-cmp:
  source_after_plugin("cmp_luasnip/after/plugin/cmp_luasnip.lua")
  source_after_plugin("cmp-buffer/after/plugin/cmp_buffer.lua")
  source_after_plugin("cmp-path/after/plugin/cmp_path.lua")
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
  Util.defer.on_keys(function()
    add("comment-box.nvim")
    require("ak.config.comment_box")
  end, "<leader>bL", "Load comment-box")
end)
