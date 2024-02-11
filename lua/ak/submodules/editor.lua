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
  require("ak.config.editor.oil")
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
  require("ak.config.editor.flash")

  add("harpoon")
  require("ak.config.editor.harpoon_one")

  add("trouble.nvim")
  require("ak.config.editor.trouble")
  add("nvim-spectre")
  require("ak.config.editor.spectre")
  add("aerial.nvim")
  require("ak.config.editor.aerial")

  add("telescope-fzf-native.nvim")
  add("telescope-alternate.nvim")
  add("telescope.nvim")
  require("ak.config.editor.telescope")

  add("mini.clue")
  require("ak.config.editor.mini_clue")

  add("gitsigns.nvim")
  require("ak.config.editor.gitsigns")
  add("vim-illuminate")
  require("ak.config.editor.illuminate")
  add("todo-comments.nvim")
  require("ak.config.editor.todo_comments")

  add("toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  Util.defer.on_keys(function()
    add("git-blame.nvim")
    require("ak.config.editor.gitblame")
  end, "<leader>gt", "Git-blame")

  Util.defer.on_keys(function()
    add("vim-hardtime")
    require("ak.config.editor.hardtime")
  end, "<leader>uh", "Hardtime")
end)
