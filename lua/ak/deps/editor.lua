local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

local pick_add_fzf = false
local hardtime_now = false

now(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Explorer                        │
  --          ╰─────────────────────────────────────────────────────────╯
  local function add_explorer() require("ak.config.editor.files") end
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
  add("ggandor/leap.nvim")
  require("ak.config.editor.leap")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                          Mini                           │
  --          ╰─────────────────────────────────────────────────────────╯
  require("ak.config.editor.clue")
  require("ak.config.editor.cursorword")
  require("ak.config.editor.hipatterns")
  require("ak.config.editor.git")
  require("ak.config.editor.diff")
  require("ak.config.editor.pick")
  if pick_add_fzf then -- download fzf on demand
    local spec_fzf = "ibhagwan/fzf-lua"
    register(spec_fzf)
    Util.defer.on_keys(function()
      now(function()
        add(spec_fzf)
        require("ak.config.editor.pick_fzf_lua")
      end)
    end, "<leader>fi", "Picker builtin")
  end
  require("ak.config.editor.visits") -- marks like grapple.nvim/harpoon, uses mini.pick

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

  -- local spec_overseer = "stevearc/overseer.nvim"
  -- register(spec_overseer)
  -- Util.defer.on_keys(function()
  --   now(function()
  --     add(spec_overseer)
  --     require("ak.config.editor.overseer")
  --   end)
  -- end, "<leader>sl", "Load overseer")
end)
