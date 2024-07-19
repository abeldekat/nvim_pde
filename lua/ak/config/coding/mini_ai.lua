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
local has_ts, _ = pcall(require, "nvim-treesitter-textobjects")

local function get_opts()
  local opts = {
    custom_textobjects = {
      -- Builtin ? interactive, favour conditional in treesitter
      ["?"] = false,

      -- Builtin a, same as treesitter: Use treesitter when available:
      a = has_ts and ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" })
        or ai.gen_spec.argument(),

      -- Overrides built-in block {}. D perhaps?
      B = MiniExtra.gen_ai_spec.buffer(),

      -- Custom, word with case:
      e = {
        { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
        "^().*()$",
      },

      -- Builtin f, different from treesitter. Operates on function call instead of entire function
      -- Use treesitter if available or or disable to avoid confusion:
      f = has_ts and ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }) or false,

      -- Remap builtin f to F
      F = ai.gen_spec.function_call(),

      -- Builtin t, disable, use Neovim builtin
      t = false,
    },
  }
  return opts
end

-- NOTE: mini.ai select, cursor is positioned on start of the selection.
ai.setup(get_opts())

vim.keymap.set(
  "n",
  "<leader>ua",
  function() vim.g.miniai_disable = not vim.g.miniai_disable end,
  { desc = "Toggle Mini.Ai", silent = true }
)
