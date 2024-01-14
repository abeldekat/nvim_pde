local autoload_clues = false

return {

  {
    "stevearc/aerial.nvim", -- event = "LazyFile",
    keys = "<leader>cs",
    config = function()
      require("ak.config.aerial")
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    -- stylua: ignore start
    keys = {
      { "s", mode = { "n", "x", "o" } }, { "S", mode = { "n", "x", "o" } },
      { "r", mode = "o" }, { "R", mode = { "o", "x" } }, { "<c-s>", mode = { "c" } },
    },
    -- stylua: ignore end
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
    "takac/vim-hardtime", -- lazy = false,
    keys = "<leader>mh",
    init = function()
      require("ak.config.hardtime").init()
    end,
    config = function()
      require("ak.config.hardtime").setup()
    end,
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      require("ak.config.harpoon")
    end,
  },

  {
    "RRethy/vim-illuminate",
    event = "LazyFile",
    keys = { "]]", "[[" }, -- next and pref reference
    config = function()
      require("ak.config.illuminate")
    end,
  },

  {
    "echasnovski/mini.clue",
    event = function()
      return autoload_clues and { "VeryLazy" } or {}
    end,
    keys = function()
      return autoload_clues and {} or { "<leader>uk" } -- activate clue
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
    keys = { "<leader>sr", desc = "Spectre" },
    config = function()
      require("ak.config.spectre")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- used in the intro screen
    version = false, -- telescope did only one release, so use HEAD for now
    -- lazy: define only the keys used when starting
    keys = { "<leader><leader>", "<leader>o", "<leader>/", "<leader>e", "<leader>r" },
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        enabled = vim.fn.executable("make") == 1,
      },
      "otavioschwanck/telescope-alternate.nvim",
      "jvgrootveld/telescope-zoxide",
      {
        "nvim-telescope/telescope-project.nvim",
        dependencies = "nvim-telescope/telescope-file-browser.nvim",
      },
    },
    config = function()
      require("ak.config.telescope")
    end,
  },

  {
    "folke/todo-comments.nvim", -- cmd = { "TodoTrouble", "TodoTelescope" },
    event = "LazyFile",
    config = function()
      require("ak.config.todo_comments")
    end,
  },

  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- cmd = { "TermExec", "ToggleTerm", "ToggleTermToggleAll", "ToggleTermSendCurrentLine",
    --   "ToggleTermSendVisualLines", "ToggleTermSendVisualSelection", },
    keys = [[<c-_>]],
    config = function()
      require("ak.config.toggleterm")
    end,
  },

  {
    "folke/trouble.nvim", -- cmd = { "TroubleToggle", "Trouble" },
    keys = { "<leader>xx", "<leader>xX", "<leader>xL", "<leader>xQ" },
    config = function()
      require("ak.config.trouble")
    end,
  },
}
