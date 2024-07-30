local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

local pick_add_fzf = false
local hardtime_now = false

now(function()
  --          ╭─────────────────────────────────────────────────────────╮
  --          │                           Oil                           │
  --          ╰─────────────────────────────────────────────────────────╯
  local function oil()
    add("stevearc/oil.nvim")
    require("ak.config.editor.oil")
  end
  -- stylua: ignore
  if Util.opened_with_dir_argument() then oil() else later(oil) end

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
  require("ak.config.editor.mini_pick").setup()
  if pick_add_fzf then -- download fzf on demand, not registered
    local spec_fzf = "ibhagwan/fzf-lua"
    register(spec_fzf)
    Util.defer.on_keys(function()
      now(function()
        add(spec_fzf)
        require("ak.config.editor.mini_pick_fzf_lua")
      end)
    end, "<leader>fi", "Picker builtin")
  end

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                         Marking                         │
  --          ╰─────────────────────────────────────────────────────────╯
  add("cbochs/grapple.nvim")
  require("ak.config.editor.grapple")

  --          ╭─────────────────────────────────────────────────────────╮
  --          │                          Other                          │
  --          ╰─────────────────────────────────────────────────────────╯
  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

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

  local spec_spectre = "nvim-pack/nvim-spectre"
  register(spec_spectre)
  Util.defer.on_keys(function()
    now(function()
      add(spec_spectre)
      require("ak.config.editor.spectre")
    end)
  end, "<leader>cR", "Replace in files (spectre)")
end)
