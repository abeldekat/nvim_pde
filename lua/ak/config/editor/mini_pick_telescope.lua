--          ╭─────────────────────────────────────────────────────────╮
--          │           Use, when needed: Telescope builtin           │
--          ╰─────────────────────────────────────────────────────────╯

-- Previous telescope config fragments:
-- searching: Telescope default is vim.uv.cwd. May also be relative to buffer
-- require("telescope.utils").buffer_dir
-- builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({ winblend = 10, previewer = false, }))
-- builtin.live_grep(themes.get_ivy({}))
-- builtin.oldfiles({ cwd_only = true })
-- builtin.buffers({ sort_mru = true, sort_lastused = true })
-- builtin.git_files({ show_untracked = true })
-- builtin.lsp_dynamic_workspace_symbols({ symbols = require("ak.consts").get_kind_filter()})
-- function() builtin.grep_string({ word_match = "-w" }) end

-- local function alternate_extension()
-- require("telescope-alternate").setup({
--   mappings = {
--     {
--       "src/(.*)/(.*).py",
--       { { "tests/**/test_[2].py", "Test", false } },
--     },
--     {
--       "tests/(.*)/test_(.*).py",
--       { { "src/**/[2].py", "Source", false } },
--     },
--   },
-- })
-- require("telescope").load_extension("telescope-alternate")
-- end

local function get_opts(use_default)
  local actions = require("telescope.actions")
  local layout_actions = require("telescope.actions.layout")

  return use_default and {}
    or {
      defaults = {
        path_display = { filename_first = { reverse_directories = false } },
        sorting_strategy = "ascending",
        layout_strategy = "flex",
        layout_config = { prompt_position = "top", flex = { flip_columns = 140 } },
        mappings = {
          i = {
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
            ["<Down>"] = layout_actions.cycle_layout_prev, -- duplicate move_selection_previous
            ["<Up>"] = layout_actions.cycle_layout_next, -- duplicate move_selection_end
            ["<a-p>"] = layout_actions.toggle_preview,
            ["<a-m>"] = layout_actions.toggle_mirror,
            ["<a-o>"] = layout_actions.toggle_prompt_position,
            ["<C-c>"] = false, -- double escape actions.close,
          },
          n = {
            ["q"] = actions.close,
            ["<Down>"] = false,
            ["<Up>"] = false,
          },
        },
      },
      -- extensions = { ["ui-select"] = { require("telescope.themes").get_dropdown() } },
    }
end

require("telescope").setup(get_opts(true))
require("telescope").load_extension("fzf")
-- require("telescope").load_extension("ui-select")
-- alternate_extension()
vim.keymap.set("n", "<leader>fP", "<cmd>Telescope builtin<cr>", { desc = "Picker builtin", silent = true })
vim.keymap.set(
  "n",
  "ml",
  -- function() require("telescope").extensions["telescope-alternate"].alternate_file() end,
  function() vim.notify("No picker for alternate file") end,
  { desc = "Alternate file", silent = true }
)
