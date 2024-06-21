local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register
local with_dir = Util.opened_with_dir_argument()

---@type "g" | "h"  -- Use either grapple or harpoon
local marker_to_use = "g"
---@type "f" | "t" -- mini.pick: Enable more pickers using telescope or fzf builtin
local picker_builtin_to_use = "f"

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Marker                          │
--          ╰─────────────────────────────────────────────────────────╯
local spec_harpoon = {
  source = "ThePrimeagen/harpoon",
  checkout = "harpoon2",
}
local spec_grapple = "cbochs/grapple.nvim"
local function marker_harpoon()
  register(spec_grapple)
  add(spec_harpoon)
  require("ak.config.editor.harpoon")
end
local function marker_grapple()
  -- register(spec_harpoon) -- download when needed, also see ui
  add(spec_grapple)
  require("ak.config.editor.grapple")
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Picker                          │
--          ╰─────────────────────────────────────────────────────────╯
local function fzf_native(params)
  vim.cmd("lcd " .. params.path)
  vim.cmd("!make -s")
  vim.cmd("lcd -")
end
local spec_telescope = {
  source = "nvim-telescope/telescope.nvim",
  depends = {
    { -- "otavioschwanck/telescope-alternate.nvim",
      source = "nvim-telescope/telescope-fzf-native.nvim",
      hooks = { post_install = fzf_native, post_checkout = fzf_native },
    },
  },
}
local spec_fzf_lua = { source = "ibhagwan/fzf-lua" }
local function picker_mini_pick()
  require("ak.config.editor.mini_pick").setup()

  register(picker_builtin_to_use == "f" and spec_fzf_lua or spec_telescope)
  Util.defer.on_keys(function()
    now(function()
      if picker_builtin_to_use == "f" then
        add(spec_fzf_lua)
        require("ak.config.editor.mini_pick_fzf_lua")
      else
        add(spec_telescope)
        require("ak.config.editor.mini_pick_telescope")
      end
    end)
  end, "<leader>fP", "Picker builtin")
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                        Hardtime                         │
--          ╰─────────────────────────────────────────────────────────╯
local spec_hardtime = "takac/vim-hardtime"
local function hardtime()
  require("ak.config.editor.hardtime")
  add(spec_hardtime)
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Load                           │
--          ╰─────────────────────────────────────────────────────────╯
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

-- Easily switch hardtime between now and later
-- now(hardtime)
later(function()
  register(spec_hardtime)
  Util.defer.on_keys(hardtime, "<leader>uH", "Hardtime")
end)

later(function()
  add("tpope/vim-repeat")
  add("ggandor/leap.nvim")
  add("ggandor/leap-spooky.nvim")
  require("ak.config.editor.leap")
  add("jinh0/eyeliner.nvim")
  require("ak.config.editor.eyeliner")

  -- stylua: ignore
  if marker_to_use == "h" then marker_harpoon() else marker_grapple() end

  add("nvim-pack/nvim-spectre")
  require("ak.config.editor.spectre")
  add("stevearc/aerial.nvim")
  require("ak.config.editor.aerial")

  picker_mini_pick()

  require("ak.config.editor.mini_clue")
  require("ak.config.editor.mini_misc")
  require("ak.config.editor.mini_cursorword")
  require("ak.config.editor.mini_hipatterns")

  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  -- add("lewis6991/gitsigns.nvim")
  -- require("ak.config.editor.gitsigns")
  require("ak.config.editor.mini_git")
  require("ak.config.editor.mini_diff")

  local spec_blame = "f-person/git-blame.nvim"
  register(spec_blame)
  Util.defer.on_keys(function()
    now(function()
      add(spec_blame)
      require("ak.config.editor.gitblame")
    end)
  end, "<leader>gt", "Git-blame")

  local spec_quickfix = {
    source = "kevinhwang91/nvim-bqf",
    depends = { { source = "yorickpeterse/nvim-pqf" } },
  }
  register(spec_quickfix)
  Util.defer.on_events(function()
    later(function()
      add(spec_quickfix)
      require("ak.config.editor.quickfix")
      vim.cmd("copen")
    end)
  end, "FileType", "qf")
end)
