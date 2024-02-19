--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins for code modificaton          │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later
local later_only = Util.defer.later_only

if Util.submodules.is_provisioning() then
  Util.submodules.print_provision("coding")

  vim.cmd("lcd " .. Util.submodules.plugin_path("LuaSnip", "coding"))
  vim.cmd("!make -s install_jsregexp")
  vim.cmd("lcd -")
  Util.info("NOTE: rm: cannot rm is not an error")
  return
end

-- Completion: Lazy loading benefit: +-5 ms
later(function()
  add("nvim-cmp")
  add("cmp-nvim-lsp") -- cmp_nvim_lsp must be present before nvim-lspconfig is added
  add("cmp_luasnip")
  add("cmp-buffer")
  add("cmp-path")
end)
-- After/plugin is not loaded when using later()
later_only(function()
  -- Plugin cmp-nvim-lsp does not require nvim-cmp but creates an autocmd on insertenter
  for _, name in ipairs({ "cmp-nvim-lsp", "cmp_luasnip", "cmp-buffer", "cmp-path" }) do
    Util.submodules.source_after(name, "coding")
  end
end)
later(function() -- and finally:
  require("ak.config.coding.cmp")
end)

later(function()
  add("nvim-autopairs")
  require("ak.config.coding.autopairs")

  add("friendly-snippets")
  add("LuaSnip")
  require("ak.config.coding.LuaSnip")

  add("nvim-ts-context-commentstring")
  add("Comment.nvim")
  require("ak.config.coding.comment")

  add("dial.nvim")
  require("ak.config.coding.dial")

  add("substitute.nvim")
  require("ak.config.coding.substitute")

  add("nvim-surround")
  require("ak.config.coding.surround")

  Util.defer.on_keys(function()
    add("comment-box.nvim")
    require("ak.config.coding.comment_box")
  end, "<leader>bL", "Load comment-box")
end)
