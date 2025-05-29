local bracketed = require("mini.bracketed")

local config = { --   ... Supply empty string `''` to not create mappings. ...
  -- buffer = { suffix = "b", options = {} },
  -- comment = { suffix = "c", options = {} },
  -- conflict = { suffix = "x", options = {} }, -- see notes in :h!
  -- diagnostic = { suffix = "d", options = {} },
  file = { suffix = "", options = {} }, -- f, using treesitter-textobjects
  indent = { suffix = "" }, -- favor mappings of mini.indentscope...
  jump = { suffix = "" }, -- not needing jump brackets...
  oldfile = { suffix = "" }, -- favor picker...
  -- location = { suffix = "l", options = {} },
  -- quickfix = { suffix = "q", options = {} },
  -- treesitter = { suffix = "t", options = {} },
  undo = { suffix = "" }, -- not doing much with undo...
  -- window = { suffix = "w", options = {} },
  yank = { suffix = "" }, -- not needing yank brackets...
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
