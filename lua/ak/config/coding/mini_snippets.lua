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

local Util = require("ak.util")
local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }

snippets.setup({
  snippets = {
    snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
    snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },

  -- Created globally. I already use <c-j> to confirm completion.
  --
  -- CTRL-K {char1} [char2] Enter digraph (see |digraphs|).
  -- I almost never enter a digraph.
  -- The key used to be overriden in ak.config.lang.lspconfig for signature help in insert mode.
  -- I also seldomly invoke signature help in insert mode.
  -- Solution: use <c-k> for snippets and <c-s> for signature help in insert mode.
  -- To enter a digraph, start nvim without plugins.
  mappings = { expand = "" }, -- map expand to <c-k> in this module
  expand = {
    select = function(the_snippets, insert, opts)
      if Util.completion == "nvim-cmp" then
        local cmp = require("cmp")
        if cmp.visible() then cmp.close() end
        MiniSnippets.default_select(the_snippets, insert, opts)
      elseif Util.completion == "blink" then
        -- Cancel uses vim.schedule
        require("blink.cmp").cancel() -- overriden in blink config!
        -- Schedule default_select, otherwise blink's virtual text is not removed
        -- when mini.snippets opens vim.ui.select
        vim.schedule(function() MiniSnippets.default_select(the_snippets, insert, opts) end)
      end
    end,
  },
})

-- create customized expand mappings:

-- The default:
-- vim.keymap.set("i", "<c-k>", "<Cmd>lua MiniSnippets.expand()<CR>", { desc = "Expand snippet" })
local expand = function() MiniSnippets.expand() end
vim.keymap.set("i", "<c-k>", expand, { desc = "Expand snippet" })

-- Add extra expand all mapping:
local expand_all = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-k>", expand_all, { desc = "Expand all snippet" })
