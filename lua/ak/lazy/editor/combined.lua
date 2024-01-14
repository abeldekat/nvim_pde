return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    config = function()
      require("ak.config.harpoon")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope", -- used in the intro screen
    version = false, -- telescope did only one release, so use HEAD for now
    keys = { -- lazy: define only the keys used when starting
      "<leader><leader>", -- search files
      "<leader>o", -- opened buffers
      "<leader>/", -- search in buffer
      "<leader>e", -- grep
      "<leader>r", -- recent files
    },
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
}
