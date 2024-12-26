-- Snippets:
-- From the help, line #444, it seems that mini.snippets would be used
-- by default in my native lsp setup in ak.config.coding.nvim-cmp.lua
-- Or is it necessary to add the expand to mini.snippets setup?

-- The help:

-- - This module implements jumping which wraps after final tabstop
--   for more flexible navigation (enhanced with by a more flexible
--   autostopping rules), while 'LuaSnip' autostops session once
--   jumping reached the final tabstop.
-- ...
-- Special tabstop `$0` is called "final tabstop": it is used to decide when
-- snippet session is automatically stopped and is visited last during jumping.

-- - Tabstop can also have choices: suggestions about tabstop text. It is denoted
--   as `${1|a,b,c|}`. Choices are shown (with |ins-completion| like interface)
--   after jumping to tabstop. First choice is used as placeholder.
--
--   Example: `T1=${1|left,right|}` is expanded as `T1=left`.

-- - Variables can be used to automatically insert text without user interaction.
--   As tabstops, each one can have a placeholder which is used if variable is
--   not defined. There is a special set of variables describing editor state.
-- ...
-- - Variable transformations are not supported during snippet session. It would
--   require interacting with ECMAScript-like regular expressions for which there
--   is no easy way in Neovim. It may change in the future.
--   Transformations are recognized during parsing, though, with some exceptions:
--     - The `}` inside `if` of `${1:?if:else}` needs escaping (for technical reasons).

-- - Stop session manually by pressing <C-c> or make it stop automatically:
--   if final tabstop is current either make a text edit or exit to Normal mode.
--   If snippet doesn't explicitly define final tabstop, it is added at the end
--   of the snippet.

-- General advice:
-- - Put files in "snippets" subdirectory of any path in 'runtimepath' (like
--   "$XDG_CONFIG_HOME/nvim/snippets/global.json").
--   This is compatible with |MiniSnippets.gen_loader.from_runtime()| and
--   example from |MiniSnippets-examples|.
-- - Prefer `*.json` files with dict-like content if you want more cross platfrom
-- setup. Otherwise use `*.lua` files with array-like content.

-- Make jump mappings or skip to use built-in <Tab>/<S-Tab> in Neovim>=0.11

local gen_loader = require("mini.snippets").gen_loader
require("mini.snippets").setup({
  snippets = {
    -- Load custom file with global snippets first
    gen_loader.from_file("~/.config/nvim/snippets/global.json"),

    -- Load snippets based on current language by reading files from
    -- "snippets/" subdirectories from 'runtimepath' directories.
    gen_loader.from_lang(),
  },

  mappings = {
    -- Expand snippet at cursor position. Created globally in Insert mode.
    -- *i_CTRL-J* *i_<NL>* <NL> or CTRL-J	Begin new line.
    expand = "<C-J>", -- "<C-j>", -- I use <c-j> to confirm completion

    -- -- Interact with default `expand.insert` session.
    -- -- Created for the duration of active session(s)
    -- jump_next = "<C-l>",
    -- jump_prev = "<C-h>",
    -- stop = "<C-c>",
  },

  --   -- Functions describing snippet expansion. If `nil`, default values
  --   -- are `MiniSnippets.default_<field>()`.
  --   expand = {
  --     -- Resolve raw config snippets at context
  --     prepare = nil,
  --     -- Match resolved snippets at cursor position
  --     match = nil,
  --     -- Possibly choose among matched snippets
  --     select = nil,
  --     -- Insert selected snippet
  --     insert = nil,
  --   },
})

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })
