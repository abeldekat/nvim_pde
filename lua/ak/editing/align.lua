-- From the help:
-- Beware of mode when selecting region :  charwise (`v`), linewise (`V`), or
-- blockwise (`<C-v>`).  They all behave differently .
--
-- Notes:
-- - Visual blockwise selection works best with 'virtualedit' equal to "block"
--   or "all".
--
-- f   : filter ( example on first column with n==1 )
-- i   : ignore some patterns( "_" vs _ )
-- p   : pair neighbouring parts ( first split, then pair -> split symbols are moved)
-- t   : Trim parts from whitespace on both sides (keeping indentation)
-- <BS>: delete some preset per kind
--
-- Special configurations for common splits
-- =: Variations on =
-- ,: , and extra filters
--  : space, ie keeps indentation
require("mini.align").setup({
  mappings = {
    start = "gA",
    start_with_preview = "ga",
  },
})
