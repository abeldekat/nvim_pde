local ai = require('mini.ai')
local e = MiniExtra

ai.setup({
  -- 'mini.ai' can be extended with custom textobjects
  custom_textobjects = {
    -- Make `aB` / `iB` act on around/inside whole *b*uffer
    B = e.gen_ai_spec.buffer(),

    -- For more complicated textobjects that require structural awareness,
    -- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
    -- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
    D = e.gen_ai_spec.diagnostic(),

    F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),

    I = e.gen_ai_spec.indent(),
    L = e.gen_ai_spec.line(),
    N = e.gen_ai_spec.number(),

    o = ai.gen_spec.treesitter({
      a = { '@block.outer', '@loop.outer', '@conditional.outer' },
      i = { '@block.inner', '@loop.inner', '@conditional.inner' },
    }),
  },

  -- 'mini.ai' by default mostly mimics built-in search behavior: first try
  -- to find textobject covering cursor, then try to find to the right.
  -- Although this works in most cases, some are confusing. It is more robust to
  -- always try to search only covering textobject and explicitly ask to search
  -- for next (`an`/`in`) or last (`al`/`il`).
  -- Try this. If you don't like it - delete next line and this comment.
  search_method = 'cover',
})
