local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register
local with_dir = Util.opened_with_dir_argument()

now(function()
  local function oil()
    add("nvim-tree/nvim-web-devicons")
    add("stevearc/oil.nvim")
    require("ak.config.editor.oil")
  end
  if with_dir then
    oil()
  else
    later(oil)
  end
end)

-- "jvgrootveld/telescope-zoxide",
-- "nvim-telescope/telescope-file-browser.nvim",
-- "nvim-telescope/telescope-project.nvim",
later(function()
  add("tpope/vim-repeat")
  add("ggandor/leap.nvim")
  add("ggandor/leap-spooky.nvim")
  require("ak.config.editor.leap")

  add("jinh0/eyeliner.nvim")
  require("ak.config.editor.eyeliner")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │ Have both harpoon and grapple installed, but "packadd"  │
  --          │                       only one...                       │
  --          ╰─────────────────────────────────────────────────────────╯
  local harpoon_spec = {
    source = "ThePrimeagen/harpoon",
    checkout = "harpoon2",
  }
  local grapple_spec = "cbochs/grapple.nvim"
  --
  register(harpoon_spec)
  -- add(harpoon_spec)
  -- require("ak.config.editor.harpoon")
  --
  -- register(grapple_spec)
  add(grapple_spec)
  require("ak.config.editor.grapple")

  require("ak.config.editor.mini_clue")
  require("ak.config.editor.mini_misc")

  add("folke/trouble.nvim")
  require("ak.config.editor.trouble")
  add("nvim-pack/nvim-spectre")
  require("ak.config.editor.spectre")
  add("stevearc/aerial.nvim")
  require("ak.config.editor.aerial")

  local function make_fzf_native(params)
    vim.cmd("lcd " .. params.path)
    vim.cmd("!make -s")
    vim.cmd("lcd -")
  end
  add({
    source = "nvim-telescope/telescope.nvim",
    depends = {
      "nvim-telescope/telescope-ui-select.nvim", -- replacing dressing.nvim
      "otavioschwanck/telescope-alternate.nvim",
      {
        source = "nvim-telescope/telescope-fzf-native.nvim",
        hooks = {
          post_install = make_fzf_native,
          post_checkout = make_fzf_native,
        },
      },
    },
  })
  require("ak.config.editor.telescope")

  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  add("lewis6991/gitsigns.nvim")
  require("ak.config.editor.gitsigns")
  -- require("ak.config.editor.mini_diff")

  require("ak.config.editor.mini_cursorword")
  require("ak.config.editor.mini_hipatterns")

  register("f-person/git-blame.nvim")
  Util.defer.on_keys(function()
    now(function()
      add("f-person/git-blame.nvim")
      require("ak.config.editor.gitblame")
    end)
  end, "<leader>gt", "Git-blame")

  register("takac/vim-hardtime")
  Util.defer.on_keys(function()
    now(function()
      add("takac/vim-hardtime")
      require("ak.config.editor.hardtime")
    end)
  end, "<leader>uh", "Hardtime")
end)
