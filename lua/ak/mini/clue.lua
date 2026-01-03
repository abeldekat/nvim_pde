-- TODO: Leader tab?
local miniclue = require('mini.clue')
 
-- stylua: ignore
miniclue.setup({
  -- Define which clues to show. By default shows only clues for custom mappings
  -- (uses `desc` field from the mapping; takes precedence over custom clue).
  clues = {
    -- This is defined in 'plugin/20_keymaps.lua' with Leader group descriptions
    Config.leader_group_clues,
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    -- This creates a submode for window resize mappings. Try the following:
    -- - Press `<C-w>s` to make a window split.
    -- - Press `<C-w>+` to increase height. Clue window still shows clues as if
    --   `<C-w>` is pressed again. Keep pressing just `+` to increase height.
    --   Try pressing `-` to decrease height.
    -- - Stop submode either by `<Esc>` or by any key that is not in submode.
    miniclue.gen_clues.windows({ submode_resize = true }),
    miniclue.gen_clues.z(),
  },
  -- Explicitly opt-in for set of common keys to trigger clue window
  triggers = {
    { mode = { 'n', 'x' }, keys = '<Leader>' }, -- Leader triggers
    { mode = 'n',          keys = '\\' },       -- mini.basics
    { mode = { 'n', 'x' }, keys = '[' },        -- mini.bracketed
    { mode = { 'n', 'x' }, keys = ']' },
    { mode = 'i',          keys = '<C-x>' },    -- Built-in completion
    { mode = { 'n', 'x' }, keys = 'g' },        -- `g` key
    { mode = { 'n', 'x' }, keys = "'" },        -- Marks
    { mode = { 'n', 'x' }, keys = '`' },
    { mode = { 'n', 'x' }, keys = '"' },        -- Registers
    { mode = { 'i', 'c' }, keys = '<C-r>' },
    { mode = 'n',          keys = '<C-w>' },    -- Window commands
    { mode = { 'n', 'x' }, keys = 'z' },        -- `z` key
  },
})
