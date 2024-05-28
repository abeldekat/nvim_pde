--      ╭────────────────────────────────────────────────────────────────╮
--      │https://gist.github.com/siduck/cc7305db586d512b5fd3f4ea73c9cc81 │
--      │                    https://0x0.st/Xrbn.mp4                     │
--      ╰────────────────────────────────────────────────────────────────╯

-- Use colors from base46 nvchad
-- The base46 plugin requires this nvconfig and compiles ui.theme
-- Activate a theme in the collection: ak.colors.lua, local color = "nvconfig"
--
-- A setup method has been added in order to use this module as a colorscheme
-- in ak.config.colors
--
-- The base46 plugin itself is only needed:
-- on initial install
-- on update
-- when the theme changes
--
-- Only use this theme **after** the plugin has been installed!

local M = {}

M.ui = {
  ------------------------------- base46 -------------------------------------
  -- hl = highlights
  hl_add = {},
  hl_override = {},
  changed_themes = {},
  theme_toggle = {}, -- { "ayu_dark", "one_light" },
  theme = "ayu_dark", -- default theme
  transparency = false,

  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  },

  telescope = { style = "borderless" }, -- borderless / bordered

  ------------------------------- nvchad_ui modules -----------------------------
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    order = nil,
    modules = nil,
  },

  -- lazyload it when there are 1+ buffers
  tabufline = {
    enabled = true,
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = nil,
  },

  nvdash = {
    load_on_startup = false,
    header = { "" },
    buttons = {},
  },

  cheatsheet = {
    theme = "grid", -- simple/grid
    excluded_groups = { "terminal (t)", "autopairs", "Nvim", "Opens" }, -- can add group name or with mode
  },

  lsp = { signature = true },

  term = {
    hl = "Normal:term,WinSeparator:WinSeparator",
    sizes = { sp = 0.3, vsp = 0.2 },
    float = {
      relative = "editor",
      row = 0.3,
      col = 0.25,
      width = 0.5,
      height = 0.4,
      border = "single",
    },
  },
}

M.base46 = {
  integrations = {},
}

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Added:                          │
--          ╰─────────────────────────────────────────────────────────╯

local function replace_word(old, new)
  local chadrc = vim.fn.stdpath("config") .. "/lua/ak/config/colors/" .. "nvconfig.lua"
  local file = io.open(chadrc, "r")
  if not file then return end

  local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
  local new_content = file:read("*all"):gsub(added_pattern, new)

  file = io.open(chadrc, "w")
  if not file then return end
  file:write(new_content)
  file:close()
end

local function select(themes_cb) -- based on nvchad ui telescope
  local default_themes = vim.fn.readdir(themes_cb())
  for index, theme in ipairs(default_themes) do
    default_themes[index] = theme:match("(.+)%..+")
  end

  local old = M.ui.theme
  vim.ui.select(default_themes, { prompt = "select base46" }, function(choice)
    if not choice then return end
    M.ui.theme = choice
    require("base46").load_all_highlights()
    replace_word(old, choice)
  end)
end

M.setup = function(themes_cb)
  vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"

  local integrations = {
    "blankline",
    "cmp",
    "defaults",
    -- "devicons",
    "git",
    "lsp",
    "mason",
    -- "nvcheatsheet",
    -- "nvdash",
    -- "nvimtree",
    "statusline",
    "syntax",
    "treesitter",
    -- "tbline",
    -- "telescope",
    -- "whichkey",
  }

  for _, filename in ipairs(integrations) do
    dofile(vim.g.base46_cache .. filename)
  end

  vim.keymap.set("n", "<leader>mb", function() select(themes_cb) end, { desc = "Select base46" })
end

return M
