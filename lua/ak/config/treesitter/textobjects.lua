--          ╭─────────────────────────────────────────────────────────╮
--          │            Should be loaded after treesitter            │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │treesitter textobjects: uses k for block, b is preserved │
--          ╰─────────────────────────────────────────────────────────╯

local repeatable_move_enabled = false -- toggle, when enabled eyeliner does not work.

local opts = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      -- TODO: test treesitter assignment
      --
      ["a="] = { query = "@assignment.outer", desc = "outer part of assignment" },
      ["i="] = { query = "@assignment.inner", desc = "inner part of assignment" },
      -- ["l="] = { query = "@assignment.lhs", desc = "left hand side of assignment" },
      ["k="] = { query = "@assignment.lhs", desc = "left hand side of assignment" },
      -- ["r="] = { query = "@assignment.rhs", desc = "right hand side of assignment" },
      ["v="] = { query = "@assignment.rhs", desc = "right hand side of assignment" },
      -- block
      ["ak"] = { query = "@block.outer", desc = "around block" },
      ["ik"] = { query = "@block.inner", desc = "inside block" },
      -- class
      ["ac"] = { query = "@class.outer", desc = "around class" },
      ["ic"] = { query = "@class.inner", desc = "inside class" },
      -- conditional: also possible: ii ai
      ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
      ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
      -- function: -- also consider @call for function only
      ["af"] = { query = "@function.outer", desc = "around function" },
      ["if"] = { query = "@function.inner", desc = "inside function" },
      -- loop
      ["al"] = { query = "@loop.outer", desc = "around loop" },
      ["il"] = { query = "@loop.inner", desc = "inside loop" },
      -- parameter
      ["aa"] = { query = "@parameter.outer", desc = "around argument" },
      ["ia"] = { query = "@parameter.inner", desc = "inside argument" },
    },
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start = {
      ["]c"] = { query = "@class.outer", desc = "Next class start" },
      ["]k"] = { query = "@block.outer", desc = "Next block start" },
      ["]f"] = { query = "@function.outer", desc = "Next function start" },
      ["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
    },
    goto_next_end = {
      ["]C"] = { query = "@class.outer", desc = "Next class end" },
      ["]K"] = { query = "@block.outer", desc = "Next block end" },
      ["]F"] = { query = "@function.outer", desc = "Next function end" },
      ["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
    },
    goto_previous_start = {
      ["[c"] = { query = "@class.outer", desc = "Previous class start" },
      ["[k"] = { query = "@block.outer", desc = "Previous block start" },
      ["[f"] = { query = "@function.outer", desc = "Previous function start" },
      ["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
    },
    goto_previous_end = {
      ["[C"] = { query = "@class.outer", desc = "Previous class end" },
      ["[K"] = { query = "@block.outer", desc = "Previous block end" },
      ["[F"] = { query = "@function.outer", desc = "Previous function end" },
      ["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
    },
  },
  swap = {
    enable = true,
    swap_next = {
      [">K"] = { query = "@block.outer", desc = "Swap next block" },
      [">F"] = { query = "@function.outer", desc = "Swap next function" },
      [">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
    },
    swap_previous = {
      ["<K"] = { query = "@block.outer", desc = "Swap previous block" },
      ["<F"] = { query = "@function.outer", desc = "Swap previous function" },
      ["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
    },
  },
}

local function toggle_repeatable_move()
  local modes = { "n", "x", "o" }

  local function notify()
    vim.api.nvim_exec_autocmds(
      "User",
      { pattern = "AkRepeatableMoveToggled", modeline = false, data = { enabled = repeatable_move_enabled } }
    )
  end
  local function enable()
    notify()
    local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
    vim.keymap.set(modes, ";", ts_repeat_move.repeat_last_move)
    vim.keymap.set(modes, ",", ts_repeat_move.repeat_last_move_opposite)
    vim.keymap.set(modes, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set(modes, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set(modes, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set(modes, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end
  local function disable()
    for _, key in ipairs({ ";", ",", "f", "F", "t", "T" }) do
      pcall(vim.keymap.del, modes, key)
    end
    notify()
  end

  repeatable_move_enabled = not repeatable_move_enabled
  -- stylua: ignore
  if repeatable_move_enabled then enable() else disable() end
end
vim.keymap.set("n", "<leader>um", toggle_repeatable_move, { desc = "Toggle treesitter repeatable move" })

-- If treesitter is already loaded, we need to run config again for textobjects:
-- In diff mode, use the default vim text objects c & C instead of the treesitter ones.
---@diagnostic disable-next-line: missing-fields
if not vim.wo.diff then require("nvim-treesitter.configs").setup({ textobjects = opts }) end
