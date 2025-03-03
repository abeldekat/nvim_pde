-- Replaces indent-blankline...

-- There are textobjects and motions to operate on scope. Support v:count and dot-repeat (in operator pending mode).
-- Disable drawing of the lines: The suggested approach is to use very big value of delay, like 10000000.

local Scope = require("mini.indentscope")
local opts = {
  --
}
Scope.setup(opts)
