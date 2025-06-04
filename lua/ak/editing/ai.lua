--   goto_left = 'g[',
--   goto_right = 'g]',

--   Default textobject is activated for identifiers from digits (0, ..., 9),
--   punctuation (like `_`, `*`, `,`, etc.), whitespace (space, tab, etc.).
--   They are designed to be treated as separators, so include only right edge

-- Magic characters: ( ) . % + - * ? [ ^ $

-- Frontier pattern, documented in lua 5.2:
-- https://www.lua.org/manual/5.2/manual.html#6.4.1

-- Downside: When inside a large function, using treesitter, mini.ai might not be able
-- to delete inside function with cover_or_next

local ai = require("mini.ai")
ai.setup({
  custom_textobjects = {
    -- Builtin ? interactive, favour conditional in texobjects
    ["?"] = false,
    ["/"] = ai.gen_spec.user_prompt(),

    -- Override default gen_spec.argument to match textobjects aa/ia:
    -- a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),

    -- Overrides built-in block {}. D perhaps?
    B = MiniExtra.gen_ai_spec.buffer(), -- also in extra: diagnostic, indent, line, number

    -- Custom, word with case:
    e = {
      { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
      "^().*()$",
    },

    -- Builtin f, different from textobjects. By default ai operates on function call instead of function body
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    -- Remap builtin f to F
    F = ai.gen_spec.function_call(),

    -- Builtin t, disable, use Neovim builtin
    t = false,
  },
})
local toggle = function() vim.g.miniai_disable = not vim.g.miniai_disable end
vim.keymap.set("n", "<leader>ua", toggle, { desc = "Toggle Mini.Ai", silent = true })
