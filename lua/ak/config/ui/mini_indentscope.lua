-- Replaces indent-blankline...

-- There are textobjects and motions to operate on scope. Support v:count and dot-repeat (in operator pending mode).

local Scope = require("mini.indentscope")
local opts = {
  --
}
Scope.setup(opts)
