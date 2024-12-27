-- NOTE: supports choices in tabstop as well as variable transformations

-- The help:
--
-- General advice:
-- - Put files in "snippets" subdirectory of any path in 'runtimepath' (like
--   "$XDG_CONFIG_HOME/nvim/snippets/global.json").
--   This is compatible with |MiniSnippets.gen_loader.from_runtime()| and
--   example from |MiniSnippets-examples|.
-- - Prefer `*.json` files with dict-like content if you want more cross platfrom
-- setup. Otherwise use `*.lua` files with array-like content.

local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }

snippets.setup({
  snippets = {
    snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
    snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },

  -- Created globally. I use <c-j> to confirm completion
  mappings = { expand = "<C-S>" }, -- TODO: find a better key
})

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })
