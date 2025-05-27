--          ╭─────────────────────────────────────────────────────────╮
--          │            Should be loaded after treesitter            │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │treesitter textobjects: uses k for block, b is preserved │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local repeatable_move_enabled = false -- toggle

local function get_opts()
  local opts = {
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
    select = {
      enable = true,
      lookahead = true,
      keymaps = { -- NOTE: Don't use 'l', interferes with mini.ai last motion
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
        -- disabled mini.ai ? interactive. mini.indentscope has ii and ai
        ["a?"] = { query = "@conditional.outer", desc = "around conditional" },
        ["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
        -- loop:
        ["ao"] = { query = "@loop.outer", desc = "around loop" },
        ["io"] = { query = "@loop.inner", desc = "inside loop" },
      },
    },
  }
  if not Util.use_mini_ai then
    opts.select.keymaps["af"] = { query = "@function.outer", desc = "around function" }
    opts.select.keymaps["if"] = { query = "@function.inner", desc = "inside function" }
    opts.select.keymaps["aa"] = { query = "@parameter.outer", desc = "around argument" }
    opts.select.keymaps["ia"] = { query = "@parameter.inner", desc = "inside argument" }
  end
  return opts
end

local function toggle_repeatable_move()
  local modes = { "n", "x", "o" }

  local function enable()
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
  end

  repeatable_move_enabled = not repeatable_move_enabled
  -- stylua: ignore
  if repeatable_move_enabled then enable() else disable() end
end

vim.keymap.set("n", "<leader>uM", toggle_repeatable_move, { desc = "Toggle treesitter repeatable move" })

-- In diff mode, use the default vim text objects c & C instead of the treesitter ones.
if not vim.wo.diff then require("nvim-treesitter-textobjects").setup(get_opts()) end
