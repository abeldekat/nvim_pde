--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins enhancing the editor          │
--          │       Main components: Harpoon, telescope and oil       │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

local M = {}

local function lazyfile()
  return { "BufReadPost", "BufNewFile", "BufWritePre" }
end

-- Load plugins when pressing the leader key for the first time:
local function on_leader_key(cb, desc)
  local key = "<leader>"
  vim.keymap.set("n", key, function()
    vim.keymap.del("n", key)
    cb()
    local escaped_key = (vim.api.nvim_replace_termcodes(key, true, true, true))
    vim.api.nvim_feedkeys(escaped_key, "mit", false) -- mit: the i is important
  end, { desc = desc, silent = true })
end

local function load_on_leader()
  vim.cmd("packadd trouble.nvim")
  require("ak.config.trouble")

  vim.cmd("packadd nvim-spectre")
  require("ak.config.spectre")

  vim.cmd("packadd aerial.nvim")
  require("ak.config.aerial")

  vim.cmd.packadd("telescope-fzf-native.nvim")
  vim.cmd("packadd telescope-alternate.nvim")
  vim.cmd("packadd telescope.nvim")
  require("ak.config.telescope")

  vim.cmd("packadd mini.clue")
  require("ak.config.clue")
end

local function load_on_lazyfile()
  vim.cmd("packadd gitsigns.nvim")
  require("ak.config.gitsigns")
  vim.cmd("packadd vim-illuminate")
  require("ak.config.illuminate")
  vim.cmd("packadd todo-comments.nvim")
  require("ak.config.todo_comments")
end

local function load_oil()
  vim.cmd("packadd nvim-web-devicons")
  vim.cmd("packadd oil.nvim")
  require("ak.config.oil").setup()
end

-- "jvgrootveld/telescope-zoxide",
-- "nvim-telescope/telescope-file-browser.nvim",
-- "nvim-telescope/telescope-project.nvim",
local editor_spec = {
  "ThePrimeagen/harpoon",
  "jinh0/eyeliner.nvim",
  "folke/flash.nvim",
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    opt = true,
  },
  { "lewis6991/gitsigns.nvim", opt = true },
  { "RRethy/vim-illuminate", opt = true },
  { "folke/todo-comments.nvim", opt = true },
  { "folke/trouble.nvim", opt = true },
  { "f-person/git-blame.nvim", opt = true },
  { "takac/vim-hardtime", opt = true },
  { "echasnovski/mini.clue", opt = true },
  { "akinsho/toggleterm.nvim", opt = true },
  { "nvim-tree/nvim-web-devicons", opt = true },
  { "stevearc/oil.nvim", opt = true },
  { "nvim-pack/nvim-spectre", opt = true },
  { "otavioschwanck/telescope-alternate.nvim", opt = true },
  { "stevearc/aerial.nvim", opt = true },
  { "nvim-telescope/telescope.nvim", opt = true },
}

function M.spec()
  return editor_spec
end

function M.setup()
  require("ak.config.harpoon_one")
  require("ak.config.jump")

  on_leader_key(function()
    load_on_leader()
  end, "Load editor plugins on leader")
  Util.paq.on_command(function() -- needed in intro
    load_on_leader()
  end, "Telescope")

  Util.paq.on_events(function()
    load_on_lazyfile()
  end, lazyfile())

  if require("ak.config.oil").needs_oil() then
    load_oil()
  else
    Util.paq.on_keys(function()
      load_oil()
    end, "mk", "Oil")
  end

  Util.paq.on_keys(function()
    vim.cmd("packadd toggleterm.nvim")
    require("ak.config.toggleterm")
  end, [[<c-_>]], "Toggleterm")

  Util.paq.on_keys(function()
    vim.cmd("packadd git-blame.nvim")
    require("ak.config.gitblame")
  end, "<leader>gt", "Git-blame")

  Util.paq.on_keys(function()
    require("ak.config.hardtime").init()
    vim.cmd("packadd vim-hardtime")
    require("ak.config.hardtime").setup()
  end, "<leader>uh", "Hardtime")
end

return M
