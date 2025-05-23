local MiniSurround = require("mini.surround")

-- asdf cannot be used for marks. Easy to remember, adjacent on keyboard.
local mappings_without_s_key = {
  add = "ma",
  delete = "md",
  find = "mf", -- Find surrounding (to the right)
  find_left = "mF", -- Find surrounding (to the left)
  highlight = "mH", -- Highlight surrounding
  replace = "ms", -- Substitute surrounding(aka change, replace)
  update_n_lines = "mN", -- Update `n_lines`
}

local opts = {
  mappings = mappings_without_s_key,
}

MiniSurround.setup(opts)
