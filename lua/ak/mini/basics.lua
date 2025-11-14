-- TODO: gO and outline?

-- Common configuration presets. Example usage:
-- - `<C-s>` in Insert mode - save and go to Normal mode
-- - `go` / `gO` - insert empty line before/after in Normal mode
-- - `gy` / `gp` - copy / paste from system clipboard
-- - `\` + key - toggle common options. Like `\h` toggles highlighting search.
-- - `<C-hjkl>` (four combos) - navigate between windows.
-- - `<M-hjkl>` in Insert/Command mode - navigate in that mode.
--
require("mini.basics").setup({
  -- Manage options in 'plugin/10_options.lua' for didactic purposes
  options = { basic = false },
  mappings = {
    -- Create `<C-hjkl>` mappings for window navigation
    windows = true,
    -- Create `<M-hjkl>` mappings for navigation in Insert and Command modes
    move_with_alt = true,
  },
})
