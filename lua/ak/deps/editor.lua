local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

Util.explorer = "mini"
local pick_add_fzf = false
local hardtime_now = false

local explorer = Util.explorer

now(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │                           Oil                           │
  --          ╰─────────────────────────────────────────────────────────╯
  local oil = "stevearc/oil.nvim"
  local function add_explorer()
    if explorer == "mini" then
      -- register(oil)
      require("ak.config.editor.mini_files")
    elseif explorer == "oil" then
      -- ["oil.nvim"] = "add50252b5e9147c0a09d36480d418c7e2737472",
      add(oil)
      require("ak.config.editor.oil")
    end
  end
  -- stylua: ignore
  if Util.opened_with_dir_argument() then add_explorer() else later(add_explorer) end

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Hardtime                        │
  --          ╰─────────────────────────────────────────────────────────╯
  local spec_hardtime = "takac/vim-hardtime"
  local function hardtime()
    require("ak.config.editor.hardtime")
    add(spec_hardtime)
  end
  if hardtime_now then
    hardtime()
  else
    later(function()
      register(spec_hardtime)
      Util.defer.on_keys(hardtime, "<leader>uH", "Hardtime")
    end)
  end
end)

later(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │                          Mini                           │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.editor.mini_clue")
  require("ak.config.editor.mini_cursorword")
  require("ak.config.editor.mini_hipatterns")
  require("ak.config.editor.mini_jump2d")
  require("ak.config.editor.mini_git")
  require("ak.config.editor.mini_diff")
  require("ak.config.editor.mini_pick")
  if pick_add_fzf then -- download fzf on demand
    local spec_fzf = "ibhagwan/fzf-lua"
    register(spec_fzf)
    Util.defer.on_keys(function()
      now(function()
        add(spec_fzf)
        require("ak.config.editor.mini_pick_fzf_lua")
      end)
    end, "<leader>fi", "Picker builtin")
  end
  require("ak.config.editor.mini_visits") -- marks like grapple.nvim/harpoon, uses mini.pick

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Quickfix                        │
  --          ╰─────────────────────────────────────────────────────────╯
  local spec_bqf = {
    source = "kevinhwang91/nvim-bqf",
    depends = { { source = "yorickpeterse/nvim-pqf" } },
  }
  add(spec_bqf)
  require("ak.config.editor.quickfix")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Terminal                        │
  --          ╰─────────────────────────────────────────────────────────╯
  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                          Other                          │
  --          ╰─────────────────────────────────────────────────────────╯

  add("ggandor/leap.nvim") -- only using treesitter incremental selection
  require("ak.config.editor.leap")

  local spec_spectre = "nvim-pack/nvim-spectre"
  register(spec_spectre)
  Util.defer.on_keys(function()
    now(function()
      add(spec_spectre)
      require("ak.config.editor.spectre")
    end)
  end, "<leader>cR", "Replace in files (spectre)")

  -- local spec_overseer = "stevearc/overseer.nvim"
  -- register(spec_overseer)
  -- Util.defer.on_keys(function()
  --   now(function()
  --     add(spec_overseer)
  --     require("ak.config.editor.overseer")
  --   end)
  -- end, "<leader>sl", "Load overseer")
end)
