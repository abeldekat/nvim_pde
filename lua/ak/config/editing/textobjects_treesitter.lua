-- Textobjects: uses k for block, b is preserved.
-- Not using repeatable_move.
-- Not using class functionality.
-- TODO: Is move useful in normal mode, when using jump2d?

local use_mini_ai = require("ak.util").use_mini_ai

require("nvim-treesitter-textobjects").setup({ select = { lookahead = true } })

-- Define your own text objects mappings similar to ip (inner paragraph) and ap (a paragraph).
local sel = require("nvim-treesitter-textobjects.select").select_textobject
local mapsel = function(lhs, query, desc, from_scm)
  desc = desc and "Select " .. desc or ""
  from_scm = from_scm or "textobjects"
  vim.keymap.set({ "x", "o" }, lhs, function() sel(query, from_scm) end, { desc = desc, silent = true })
end

mapsel("a=", "@assignment.outer", "around assignment")
mapsel("i=", "@assignment.inner", "inside assignment")
mapsel("k=", "@assignment.lhs", "lhs of assignment")
mapsel("v=", "@assignment.rhs", "rhs of assignment")
mapsel("ak", "@block.outer", "around block")
mapsel("ik", "@block.inner", "inside block")
-- mapsel("ac", "@class.outer", "around class")
-- mapsel("ic", "@class.inner", "inside class")
mapsel("ao", "@loop.outer", "around loop")
mapsel("io", "@loop.inner", "inside loop")

-- Use a? and i? instead of mini.ai interactive. mini.indentscope has ii and ai:
mapsel("a?", "@conditional.outer", "around conditional")
mapsel("i?", "@conditional.inner", "inside conditional")
if not use_mini_ai then -- NOTE: Don't use 'l', interferes with mini.ai last motion
  mapsel("af", "@function.outer", "around function")
  mapsel("if", "@function.inner", "inside function")
  mapsel("aa", "@parameter.outer", "around argument")
  mapsel("ia", "@parameter.inner", "inside argument")
end

-- Define your own mappings to swap the node under the cursor with the next or previous one,
-- like function parameters or arguments.
local swap = require("nvim-treesitter-textobjects.swap")
local swap_next = swap.swap_next
local swap_prev = swap.swap_prev
local mapswap = function(lhs, rhs_function, query, desc)
  desc = desc and "Swap " .. desc or ""
  vim.keymap.set("n", lhs, function() rhs_function(query) end, { desc = desc, silent = true })
end

mapswap(">K", swap_next, "@block.outer", "next block")
mapswap(">F", swap_next, "@function.outer", "next function")
mapswap(">A", swap_next, "@parameter.inner", "next argument")
mapswap("<K", swap_prev, "@block.outer", "previous block")
mapswap("<F", swap_prev, "@function.outer", "previous function")
mapswap("<A", swap_prev, "@parameter.inner", "previous argument")

-- Define your own mappings to jump to the next or previous text object.
-- This is similar to ]m, [m, ]M, [M Neovim's mappings to jump to the next or previous function.
local move = require("nvim-treesitter-textobjects.move")
local move_next_start = move.goto_next_start
local move_next_end = move.goto_next_end
local move_prev_start = move.goto_prev_start
local move_prev_end = move.goto_prev_end
local mapmove = function(lhs, rhs_function, query, desc, from_scm)
  from_scm = from_scm or "textobjects"
  vim.keymap.set({ "n", "x", "o" }, lhs, function() rhs_function(query, from_scm) end, { desc = desc, silent = true })
end

-- mapmove("]c", move_next_start, "@class.outer", "Next class start")
mapmove("]k", move_next_start, "@block.outer", "Next block start")
mapmove("]f", move_next_start, "@function.outer", "Next function start")
mapmove("]a", move_next_start, "@parameter.inner", "Next argument start")
-- mapmove("]C", move_next_end, "@class.outer", "Next class end")
mapmove("]K", move_next_end, "@block.outer", "Next block end")
mapmove("]F", move_next_end, "@function.outer", "Next function end")
mapmove("]A", move_next_end, "@parameter.inner", "Next argument end")
-- mapmove("[c", move_prev_start, "@class.outer", "Previous class start")
mapmove("[k", move_prev_start, "@block.outer", "Previous block start")
mapmove("[f", move_prev_start, "@function.outer", "Previous function start")
mapmove("[a", move_prev_start, "@parameter.inner", "Previous argument start")
-- mapmove("[C", move_prev_end, "@class.outer", "Previous class end")
mapmove("[K", move_prev_end, "@block.outer", "Previous block end")
mapmove("[F", move_prev_end, "@function.outer", "Previous function end")
mapmove("[A", move_prev_end, "@parameter.inner", "Previous argument end")
