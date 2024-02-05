--          ╭─────────────────────────────────────────────────────────╮
--          │          Contains plugins enhancing the editor          │
--          │       Main components: Harpoon, telescope and oil       │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later
local with_dir = Util.opened_with_dir_argument()

if Util.submodules.is_provisioning() then
  Util.submodules.print_provision("editor")

  vim.cmd("lcd " .. Util.submodules.file_in_pack_path("editor", { "telescope-fzf-native.nvim" }))
  vim.cmd("!make -s")
  vim.cmd("lcd -")
  return
end

local function oil()
  add("nvim-web-devicons")
  add("oil.nvim")
  require("ak.config.oil")
end
if with_dir then
  oil()
else
  later(oil)
end

-- "jvgrootveld/telescope-zoxide",
-- "nvim-telescope/telescope-file-browser.nvim",
-- "nvim-telescope/telescope-project.nvim",
later(function()
  add("eyeliner.nvim")
  add("flash.nvim")
  require("ak.config.jump")

  add("harpoon")
  require("ak.config.harpoon_one")

  add("trouble.nvim")
  require("ak.config.trouble")
  add("nvim-spectre")
  require("ak.config.spectre")
  add("aerial.nvim")
  require("ak.config.aerial")

  add("telescope-fzf-native.nvim")
  add("telescope-alternate.nvim")
  add("telescope.nvim")
  require("ak.config.telescope")

  add("mini.clue")
  require("ak.config.mini_clue")

  add("gitsigns.nvim")
  require("ak.config.gitsigns")
  add("vim-illuminate")
  require("ak.config.illuminate")
  add("todo-comments.nvim")
  require("ak.config.todo_comments")

  add("toggleterm.nvim")
  require("ak.config.toggleterm")

  Util.defer.on_keys(function()
    add("git-blame.nvim")
    require("ak.config.gitblame")
  end, "<leader>gt", "Git-blame")

  Util.defer.on_keys(function()
    add("vim-hardtime")
    require("ak.config.hardtime")
  end, "<leader>uh", "Hardtime")
end)
