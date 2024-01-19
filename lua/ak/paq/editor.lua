local M = {}

-- local function no_replay() end
-- vim.keymap.set("n", "<leader>uk", function()
--   --          ╭─────────────────────────────────────────────────────────╮
--   --          │   Load important plugins having lazy keys in order for  │
--   --          │            the descriptions to show in mini.clue        │
--   --          ╰─────────────────────────────────────────────────────────╯
--   pcall(require, "aerial")
--   pcall(require, "mini.clue")
--   pcall(require, "spectre")
--   pcall(require, "telescope")
--   pcall(require, "todo-comments")
--   pcall(require, "trouble")
--   vim.keymap.del("n", "<leader>uk")
-- end, { desc = "Load lazy editor", silent = true })

local editor_spec = {

  "jinh0/eyeliner.nvim",
  "folke/flash.nvim", -- loads fast, maybe 3ms, always used
  --

  -- "f-person/git-blame.nvim", -- keys = "<leader>gt",
  "lewis6991/gitsigns.nvim",
  --
  "takac/vim-hardtime",
  "RRethy/vim-illuminate",
  --
  "echasnovski/mini.clue",
  --
  "nvim-tree/nvim-web-devicons",
  "stevearc/oil.nvim",
  --
  "nvim-pack/nvim-spectre",
  --
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },
  "otavioschwanck/telescope-alternate.nvim",
  -- "jvgrootveld/telescope-zoxide",
  -- "nvim-telescope/telescope-file-browser.nvim",
  -- "nvim-telescope/telescope-project.nvim",
  "stevearc/aerial.nvim",
  "nvim-telescope/telescope.nvim",
  --
  "folke/todo-comments.nvim",
  "akinsho/toggleterm.nvim",
  "folke/trouble.nvim",
}
function M.spec()
  return editor_spec
end
function M.setup()
  require("ak.config.jump")
  -- require("ak.config.gitblame") -- cmd
  require("ak.config.gitsigns") -- event
  require("ak.config.hardtime").init() -- key
  require("ak.config.hardtime").setup()
  require("ak.config.illuminate") -- event
  require("ak.config.clue") -- key
  require("ak.config.oil").init() -- key
  require("ak.config.oil").setup()
  require("ak.config.spectre") -- key, build = false
  --
  require("ak.config.aerial")
  require("ak.config.telescope") -- cmd keys
  --
  require("ak.config.todo_comments") -- event
  require("ak.config.toggleterm") -- key version *
  require("ak.config.trouble") -- event
end
return M
