local autoload_clues = false

--          ╭─────────────────────────────────────────────────────────╮
--          │     Lazy keys that are not overridden in the config     │
--          │          Example: <leader>uk, loads mini.clue.          │
--          │   Without this function, the keystrokes "uk" would be   │
--          │                        replayed                         │
--          ╰─────────────────────────────────────────────────────────╯
local function no_replay() end

vim.keymap.set("n", "<leader>uk", function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │   Load important plugins having lazy keys in order for  │
  --          │            the descriptions to show in mini.clue        │
  --          ╰─────────────────────────────────────────────────────────╯
  pcall(require, "aerial")
  pcall(require, "mini.clue")
  pcall(require, "spectre")
  pcall(require, "telescope")
  pcall(require, "todo-comments")
  pcall(require, "trouble")
  vim.keymap.del("n", "<leader>uk")
end, { desc = "Load lazy editor", silent = true })

return {

  {
    "folke/flash.nvim", -- loads fast, maybe 3ms, always used
    dependencies = "jinh0/eyeliner.nvim",
    config = function()
      require("ak.config.jump")
    end,
  },

  {
    "f-person/git-blame.nvim", -- keys = "<leader>gt",
    cmd = "GitBlameToggle",
    config = function()
      require("ak.config.gitblame")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    config = function()
      require("ak.config.gitsigns")
    end,
  },

  {
    "takac/vim-hardtime",
    keys = "<leader>uh",
    init = function()
      require("ak.config.hardtime").init()
    end,
    config = function()
      require("ak.config.hardtime").setup()
    end,
  },

  {
    "ThePrimeagen/harpoon",
    -- branch = "harpoon2",
    config = function()
      -- require("ak.config.harpoon")
      require("ak.config.harpoon_one")
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "LazyFile",
    config = function()
      require("ak.config.illuminate")
    end,
  },

  {
    "echasnovski/mini.clue",
    event = function()
      return autoload_clues and { "VeryLazy" } or {}
    end,
    config = function()
      require("ak.config.clue")
    end,
  },

  {
    "stevearc/oil.nvim",
    init = function()
      require("ak.config.oil").init()
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = "mk",
    config = function()
      require("ak.config.oil").setup()
    end,
  },

  {
    "nvim-pack/nvim-spectre",
    build = false,
    keys = "<leader>sr",
    config = function()
      require("ak.config.spectre")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- used by the keys in the intro screen
    version = false, -- telescope did only one release, so use HEAD for now
    -- lazy: define only the keys used when starting
    keys = { "<leader><leader>", "<leader>o", "<leader>/", "<leader>e", "<leader>r" },
    dependencies = { -- extensions: Also uses flash!
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
      "otavioschwanck/telescope-alternate.nvim",
      -- "jvgrootveld/telescope-zoxide",
      -- {
      --   "nvim-telescope/telescope-project.nvim",
      --   dependencies = "nvim-telescope/telescope-file-browser.nvim",
      -- },
      {
        "stevearc/aerial.nvim",
        keys = "<leader>cs", -- also load on key
        config = function()
          require("ak.config.aerial")
        end,
      },
    },
    config = function()
      require("ak.config.telescope")
    end,
  },

  {
    "folke/todo-comments.nvim",
    event = "LazyFile",
    config = function()
      require("ak.config.todo_comments")
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = [[<c-_>]],
    config = function()
      require("ak.config.toggleterm")
    end,
  },

  {
    "folke/trouble.nvim",
    keys = { "<leader>xx", "<leader>xX", "<leader>xL", "<leader>xQ" },
    config = function()
      require("ak.config.trouble")
    end,
  },
}
