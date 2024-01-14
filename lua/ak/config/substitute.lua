-- dependencies = {
--   { -- three superficially unrelated plugins: working with variants of a word.
--     -- coercion (ie coerce to snake_case) crs --> Adds a cr mapping!
--     -- abolish iabbrev, subvert substitution
--     "tpope/vim-abolish",
--     config = function()
--       vim.cmd("Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}")
--     end,
--   },
-- },
require("substitute").setup({ -- range: S fails to substitute using abolish
  highlight_substituted_text = { enabled = false },
})

vim.keymap.set("n", "gs", function()
  require("substitute").operator()
end, { desc = "Substitute operator", silent = true })
-- {"gss", function() require("substitute").line() end, desc = "Substitute line"},
vim.keymap.set("x", "gs", function()
  require("substitute").visual()
end, { desc = "Substitute visual", silent = true })
-- no "S" for eol, use dollar

vim.keymap.set("n", "gx", function()
  require("substitute.exchange").operator()
end, { desc = "Exchange operator", silent = true })
-- {"gxx", function() require("substitute.exchange").line() end, desc = "Exchange line"},
vim.keymap.set("x", "gx", function()
  require("substitute.exchange").visual()
end, { desc = "Exchange visual", silent = true })

-- Using gm instead of <leader>s.
-- Mnemonic for now: go more, go multiply as in mini.operators
-- also uses a register if specified, instead of the prompt
vim.keymap.set("n", "gm", function()
  require("substitute.range").operator()
end, { desc = "Range operator", silent = true })
vim.keymap.set("n", "gmm", function()
  require("substitute.range").word()
end, { desc = "Range word", silent = true })
vim.keymap.set("x", "gm", function()
  require("substitute.range").visual()
end, { desc = "Range visual", silent = true })
