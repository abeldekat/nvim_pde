local MiniSurround = require("mini.surround")

local opts = {
  -- Add custom surroundings to be used on top of builtin ones.
  -- custom_surroundings = nil,

  -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
  -- highlight_duration = 500,

  -- add delete find find_left highlight replace update_n_lines(sn)
  -- suffix_last suffix_next examples:
  -- sdn: delete next surrounding sdl: delete last surrounding
  mappings = {
    -- use substitute mnemonic for consistency with mini.operators
    replace = "ss",
  },

  -- Number of lines within which surrounding is searched
  -- n_lines = 20,

  -- Whether to respect selection type:
  -- - Place surroundings on separate lines in linewise mode.
  -- - Place surroundings on each line in blockwise mode.
  -- respect_selection_type = false,

  -- How to search for surrounding (first inside current line, then inside
  -- neighborhood). One of 'cover', 'cover_or_next', 'cover_or_prev',
  -- 'cover_or_nearest', 'next', 'prev', 'nearest'. For more details,
  -- see `:h MiniSurround.config`.
  -- search_method = "cover",

  -- Whether to disable showing non-error feedback
  -- silent = false,
}
MiniSurround.setup(opts)
