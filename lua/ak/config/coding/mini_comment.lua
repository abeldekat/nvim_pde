--          ╭─────────────────────────────────────────────────────────╮
--          │                   What it doesn't do:                   │
--          │  - Block and sub-line comments. This will only support  │
--          │                  per-line commenting.                   │
--          │                                                         │
--          │     - Handle indentation with mixed tab and space.      │
--          │                                                         │
--          │     - Preserve trailing whitespace in empty lines.      │
--          ╰─────────────────────────────────────────────────────────╯

-- Notes:
-- - To use tree-sitter aware commenting, global value of 'commentstring'
--   should be `''` (empty string). This is the default value in Neovim>=0.9,
--   so make sure to not set it manually.

-- local opts = {
--   -- Options which control module behavior
--   options = {
--     -- Function to compute custom 'commentstring' (optional)
--     custom_commentstring = nil,
--
--     -- Whether to ignore blank lines
--     ignore_blank_line = false,
--
--     -- Whether to recognize as comment only lines without indent
--     start_of_line = false,
--
--     -- Whether to ensure single space pad for comment parts
--     pad_comment_parts = true,
--   },
--
--   -- Module mappings. Use `''` (empty string) to disable one.
--   mappings = {
--     -- Toggle comment (like `gcip` - comment inner paragraph) for both
--     -- Normal and Visual modes
--     comment = "gc",
--
--     -- Toggle comment on current line
--     comment_line = "gcc",
--
--     -- Toggle comment on visual selection
--     comment_visual = "gc",
--
--     -- Define 'comment' textobject (like `dgc` - delete whole comment block)
--     -- Works also in Visual mode if mapping differs from `comment_visual`
--     textobject = "gc",
--   },
--
--   -- Hook functions to be executed at certain stage of commenting
--   hooks = {
--     -- Before successful commenting. Does nothing by default.
--     pre = function() end,
--     -- After successful commenting. Does nothing by default.
--     post = function() end,
--   },
-- }
local function get_opts()
  local opts = {}
  return opts
end

require("mini.comment").setup(get_opts())
