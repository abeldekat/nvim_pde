local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register
local with_dir = Util.opened_with_dir_argument()

---@type "g" | "h"  -- Use either grapple or harpoon
local marker_to_use = "g"

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
local function picker_mini_pick()
  require("ak.config.editor.mini_pick").setup()
  -- register("ibhagwan/fzf-lua")
  -- Util.defer.on_keys(function()
  --   now(function()
  --     add("ibhagwan/fzf-lua")
  --     require("ak.config.editor.mini_pick_fzf_lua")
  --   end)
  -- end, "<leader>fi", "Picker builtin")
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
    require("ak.config.editor.mini_icons")
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
  -- repeat: for now, avoid the new commits in 2024
  add({ source = "tpope/vim-repeat", checkout = "24afe922e6a05891756ecf331f39a1f6743d3d5a" })
  add("ggandor/leap.nvim")
  require("ak.config.editor.leap")

  add("jinh0/eyeliner.nvim")
  require("ak.config.editor.eyeliner")

  -- stylua: ignore
  if marker_to_use == "g" then marker_grapple() else marker_harpoon() end

  add("stevearc/aerial.nvim")
  require("ak.config.editor.aerial")

  picker_mini_pick()

  require("ak.config.editor.mini_clue")
  require("ak.config.editor.mini_cursorword")
  require("ak.config.editor.mini_hipatterns")

  add("akinsho/toggleterm.nvim")
  require("ak.config.editor.toggleterm")

  require("ak.config.editor.mini_git")
  require("ak.config.editor.mini_diff")

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
