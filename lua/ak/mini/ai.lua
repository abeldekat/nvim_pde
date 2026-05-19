---@diagnostic disable: undefined-global

local ai = require('mini.ai')
local e = MiniExtra

ai.setup({
  custom_textobjects = {
    -- B = e.gen_ai_spec.buffer(),-- TODO: Test builtin nightly 'al' all lines
    -- L = e.gen_ai_spec.line(), -- TODO: Test builtin nightly 'il' inside line

    D = e.gen_ai_spec.diagnostic(),
    I = e.gen_ai_spec.indent(),
    N = e.gen_ai_spec.number(),

    F = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    o = ai.gen_spec.treesitter({
      a = { '@block.outer', '@loop.outer', '@conditional.outer' },
      i = { '@block.inner', '@loop.inner', '@conditional.inner' },
    }),
  },

  mappings = {
    around_last = 'aL', -- Not using 'last' often. Mostly using 'next'...
    inside_last = 'iL',
  },

  search_method = 'cover',
})
