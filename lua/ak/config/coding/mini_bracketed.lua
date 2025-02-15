local bracketed = require("mini.bracketed")

local config = {
  -- First-level elements are tables describing behavior of a target:
  --
  -- - <suffix> - single character suffix. Used after `[` / `]` in mappings.
  --   For example, with `b` creates `[B`, `[b`, `]b`, `]B` mappings.
  --   Supply empty string `''` to not create mappings.
  --
  -- - <options> - table overriding target options.
  --
  -- See `:h MiniBracketed.config` for more info.

  -- buffer = { suffix = "b", options = {} },
  -- comment = { suffix = "c", options = {} },
  -- conflict = { suffix = "x", options = {} },
  -- diagnostic = { suffix = "d", options = {} },
  -- file = { suffix = "f", options = {} },
  -- indent = { suffix = "i", options = {} },
  -- jump = { suffix = "j", options = {} },
  -- location = { suffix = "l", options = {} },
  -- oldfile = { suffix = "o", options = {} },
  -- quickfix = { suffix = "q", options = {} },
  -- treesitter = { suffix = "t", options = {} },
  -- undo = { suffix = "u", options = {} },
  -- window = { suffix = "w", options = {} },
  -- yank = { suffix = "y", options = {} },
}
bracketed.setup(config)

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = opts.silent ~= false
  if opts.remap and not vim.g.vscode then opts.remap = nil end
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- In normal mode, <C-W>d (and <C-W><C-D>) map to vim.diagnostic.open_float().
-- map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
--
-- Diagnostic:
local diagnostic_goto = function(next, severity)
  return function()
    MiniBracketed.diagnostic(next and "forward" or "backward", {
      severity = severity,
    })
  end
end
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev error" })
-- Goto warning uses w, same as bracketed.window
-- map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next warning" })
-- map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev warning" })
