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
  local spec_harpoon = {
    source = "ThePrimeagen/harpoon",
    checkout = "harpoon2",
  }
  register(spec_harpoon)
  -- add(harpoon_spec)
  -- require("ak.config.editor.harpoon")
  --
  local spec_grapple = "cbochs/grapple.nvim"
  -- register(grapple_spec)
  add(spec_grapple)
  require("ak.config.editor.grapple")

  add("nvim-pack/nvim-spectre")
  require("ak.config.editor.spectre")
  add("stevearc/aerial.nvim")
  require("ak.config.editor.aerial")

  local function make_fzf_native(params)
    vim.cmd("lcd " .. params.path)
    vim.cmd("!make -s")
    vim.cmd("lcd -")
  end
  -- "jvgrootveld/telescope-zoxide",
  -- "nvim-telescope/telescope-file-browser.nvim",
  -- "nvim-telescope/telescope-project.nvim",
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

  require("ak.config.editor.mini_clue")
  require("ak.config.editor.mini_misc")
  require("ak.config.editor.mini_cursorword")
  require("ak.config.editor.mini_hipatterns") -- uses telescope

  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  add("lewis6991/gitsigns.nvim")
  require("ak.config.editor.gitsigns")

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
  end, "<leader>uH", "Hardtime")

  local quickfix_spec = {
    source = "kevinhwang91/nvim-bqf",
    depends = { { source = "yorickpeterse/nvim-pqf" } },
  }
  register(quickfix_spec)
  Util.defer.on_events(function()
    later(function()
      add(quickfix_spec)
      require("ak.config.editor.quickfix")
      vim.cmd("copen")
    end)
  end, "FileType", "qf")
end)
