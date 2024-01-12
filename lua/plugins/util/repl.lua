-- iron.nvim does not work consistently
-- {
--   "Vigemus/iron.nvim",
--   enabled = true,
--   keys = {
--     { "<leader>or", "<cmd>IronRepl<cr>", desc = "Start repl" },
--     -- { "<leader>or", "<cmd>IronRestart<cr>", "Restart repl" },
--     { "<leader>of", "<cmd>IronFocus<cr>", desc = "Focus repl" },
--     { "<leader>oh", "<cmd>IronHide<cr>", desc = "Hide repl" },
--   },
--   main = "iron.core",
--   opts = function(_, _)
--     return {
--       config = {
--         -- Whether a repl should be discarded or not
--         scratch_repl = false,
--         -- Your repl definitions come here
--         repl_definition = {
--           sh = {
--             -- Can be a table or a function that
--             -- returns a table (see below)
--             command = { "zsh" },
--           },
--         },
--         -- How the repl window will be displayed
--         -- See below for more information
--         repl_open_cmd = "vertical botright 80 split",
--         -- repl_open_cmd = require("iron.view").bottom(40),
--       },
--       keymaps = {
--         send_motion = "<space>sc",
--         visual_send = "<space>sc",
--         send_file = "<space>sf",
--         send_line = "<space>sl",
--         send_until_cursor = "<space>su",
--         send_mark = "<space>sm",
--         mark_motion = "<space>mc",
--         mark_visual = "<space>mc",
--         remove_mark = "<space>md",
--         cr = "<space>s<cr>",
--         interrupt = "<space>s<space>",
--         exit = "<space>sq",
--         clear = "<space>cl",
--       },
--       -- If the highlight is on, you can change how it looks
--       -- For the available options, check nvim_set_hl
--       highlight = {
--         italic = true,
--       },
--       ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
--     }
--   end,
-- },
return {
  -- Find neovim terminal job id: echo &channel
  -- After repl starts: use <c-c><c-c>
  "jpalardy/vim-slime",
  keys = { { "<leader>mr", "<cmd>echom &channel<cr>", desc = "Repl" } },
  init = function()
    vim.g.slime_target = "neovim"
  end,
}
