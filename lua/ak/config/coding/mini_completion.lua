-- In insertmode, words in buffer, ctrl-n
-- Also ctrl-x ctrl-n. See :h ins-completion
-- ctrl-x ctrl-u: user defined completion

-- Questions:
-- Can I use ctrl-j to confirm?
-- Better keymap to force completion that does not interfere with tmux
-- Is it possible to preselect the first item?
-- Are there situations that completion should be disabled
-- Source_func: What's the motivation to change this setting
-- How to use dadbod completion? Omnifunc? Trouble typing ctrl-x
-- When to use the template in the help to get more consistent <CR> behavior

-- From the help

-- - User can force two-stage completion via
--   |MiniCompletion.complete_twostage()| (by default is mapped to
--   `<C-Space>`) or fallback completion via
--   |MiniCompletion.complete_fallback()| (mapped to `<M-Space>`).

-- - LSP kind highlighting ("Function", "Keyword", etc.). Requires Neovim>=0.11.
--   By default uses "lsp" category of |MiniIcons| (if enabled). Can be customized
--   via `config.lsp_completion.process_items` by adding field <kind_hlgroup>
--   (same meaning as in |complete-items|) to items.

-- - Makes |mini.completion| show icons, as it uses built-in protocol map.
-- - Results in loading whole `vim.lsp` module, so might add significant amount
--   of time on startup. Call it lazily. For example, with |MiniDeps.later()|: >
MiniIcons.tweak_lsp_kind()

require("mini.completion").setup({
  mappings = { -- Tmux conflict:
    force_twostep = "", --  "<C-Space>", -- Force two-step completion
    force_fallback = "", -- "<A-Space>", -- Force fallback completion
  },

  lsp_completion = { -- current setup echasnovski
    source_func = "omnifunc",
    auto_setup = false,
    -- process_items = function(items, base)
    --   -- Don't show 'Text' and 'Snippet' suggestions
    --   items = vim.tbl_filter(function(x) return x.kind ~= 1 and x.kind ~= 15 end, items)
    --   return MiniCompletion.default_process_items(items, base)
    -- end,
  },

  window = {
    info = { border = "double" },
    signature = { border = "double" },
  },
})

if vim.fn.has("nvim-0.11") == 1 then
  vim.opt.completeopt:append("fuzzy") -- Use fuzzy matching for built-in completion
end
