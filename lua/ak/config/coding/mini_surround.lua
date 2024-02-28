local MiniSurround = require("mini.surround")
local use_as_vim_surround = false

local function get_opts()
  if use_as_vim_surround then
    -- -- Remap adding surrounding to Visual mode selection
    -- vim.keymap.del("x", "ys")
    -- vim.keymap.set("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })

    -- Make special mapping for "add surrounding for line"
    vim.keymap.set("n", "yzz", "yz_", { remap = true })
    return {
      mappings = {
        add = "yz",
        delete = "dz",
        find = "",
        find_left = "",
        highlight = "",
        replace = "cz",
        update_n_lines = "",

        -- Add this only if you don't want to use extended mappings
        suffix_last = "",
        suffix_next = "",
      },
      search_method = "cover_or_next",
    }
  end

  return {
    -- Add custom surroundings to be used on top of builtin ones. For more
    -- information with examples, see `:h MiniSurround.config`.
    -- custom_surroundings = nil,

    -- Duration (in ms) of highlight when calling `MiniSurround.highlight()`
    -- highlight_duration = 500,

    --          ╭─────────────────────────────────────────────────────────╮
    --          │   the s is already taken by flash, and gs is too long   │
    --          │  use m in combination with four adjacent keys: a(add)   │
    --          │                     s(substitute),                      │
    --          │                   d(delete), f(find)                    │
    --          ╰─────────────────────────────────────────────────────────╯

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
      add = "ma", -- Add surrounding in Normal and Visual modes
      delete = "md", -- Delete surrounding
      find = "mf", -- Find surrounding (to the right)
      find_left = "mF", -- Find surrounding (to the left)
      highlight = "mh", -- Highlight surrounding
      replace = "ms", -- Substitute surrounding(aka change, replace)
      update_n_lines = "mn", -- Update `n_lines`

      suffix_last = "l", -- Suffix to search with "prev" method
      suffix_next = "n", -- Suffix to search with "next" method
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
end

MiniSurround.setup(get_opts())
