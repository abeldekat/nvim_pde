local hipatterns = require("mini.hipatterns")
local hi_words = MiniExtra.gen_highlighter.words
hipatterns.setup({
  highlighters = {
    -- Highlight a fixed set of common words. Will be highlighted in any place,
    -- not like "only in comments".
    fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
    hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
    todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
    note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),

    -- Highlight hex color string (#aabbcc) with that color as a background
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})
