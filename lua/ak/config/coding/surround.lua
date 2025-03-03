local MiniSurround = require("mini.surround")
local using_leap = true

local mappings_with_jump2d = { -- use substitute mnemonic for consistency with mini.operators
  replace = "ss",
}

-- asdf cannot be used for marks. Easy to remember, adjacent on keyboard.
local mappings_with_leap = {
  add = "ma",
  delete = "md",
  find = "mf", -- Find surrounding (to the right)
  find_left = "mF", -- Find surrounding (to the left)
  highlight = "mH", -- Highlight surrounding
  replace = "ms", -- Substitute surrounding(aka change, replace)
  update_n_lines = "mN", -- Update `n_lines`
}

local opts = {
  mappings = using_leap and mappings_with_leap or mappings_with_jump2d,
}

MiniSurround.setup(opts)
