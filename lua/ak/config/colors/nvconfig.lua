--      ╭────────────────────────────────────────────────────────────────╮
--      │https://gist.github.com/siduck/cc7305db586d512b5fd3f4ea73c9cc81 │
--      │                    https://0x0.st/Xrbn.mp4                     │
--      ╰────────────────────────────────────────────────────────────────╯

-- Use colors from the collection in plugin base46 from nvchad
-- The base46 plugin requires this nvconfig and compiles ui.theme
--
-- Activate the collection:
--   In ak.colors.lua, set local color = "nvconfig"
-- In order to switch back to regular themes, undo the above and restart nvim.
-- Only use this collection **after** plugin base64 has been installed!
--
-- Methods have been added in order to use this module as a colorscheme
-- in ak.config.colors
--
-- The base46 plugin itself is only needed:
-- on initial install
-- on update
-- when the theme changes

local M = {}

M.ui = {
  hl_add = {
    MiniStatuslineFilename = { bg = "statusline_bg" },
    MiniStatuslineModeNormal = { bg = "statusline_bg" },
    MiniStatuslineModeInsert = { bg = "green", fg = "black", bold = true },
    MiniStatuslineModeReplace = { bg = "red", fg = "black", bold = true },
    MiniStatuslineModeCommand = { bg = "yellow", fg = "black", bold = true },
    MiniStatuslineModeOther = { bg = "blue", fg = "black", bold = true },
    MiniStatuslineModeVisual = { bg = "dark_purple", fg = "black", bold = true },

    MiniHipatternsFixme = { bg = "red", fg = "black", bold = true },
    MiniHipatternsHack = { bg = "yellow", fg = "black", bold = true },
    MiniHipatternsTodo = { bg = "blue", fg = "black", bold = true },
    MiniHipatternsNote = { bg = "green", fg = "black", bold = true },
  },
  hl_override = {},
  changed_themes = {},
  theme_toggle = {},
  theme = "melange",
  transparency = false,
  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  },
  telescope = { style = "borderless" }, -- borderless / bordered

  ------------------------------- nvchad_ui modules -----------------------------
  -- Removed integrations nvdash, cheatsheet, tabufline and term:
  statusline = { theme = "default", separator_style = "default" },
  lsp = { signature = true },
}
-- Dummy, used in module base46.init.lua, adding to its local integrations
M.base46 = { integrations = {} }

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Added:                          │
--          ╰─────────────────────────────────────────────────────────╯

vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"
local integrations = {
  "blankline",
  "cmp",
  "defaults",
  -- "devicons",
  "git",
  "lsp",
  "mason",
  "statusline", -- needed for starter
  "syntax",
  "treesitter",
  -- "telescope",
}

-- Override base46.load_all_highlights to only load selected integrations
local function load_all_highlights()
  for _, filename in ipairs(integrations) do
    dofile(vim.g.base46_cache .. filename)
  end
end

local function persist(old, new)
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

    require("plenary.reload").reload_module("base46")
    M.compile()
    load_all_highlights()
    pcall(function() require("ibl").update() end)
    persist(old, choice)
  end)
end

-- Override base46.compile to only compile selected integrations
M.compile = function()
  local base46 = require("base46")
  if not vim.loop.fs_stat(vim.g.base46_cache) then vim.fn.mkdir(vim.g.base46_cache, "p") end

  for _, filename in ipairs(integrations) do
    base46.saveStr_to_cache(filename, base46.load_integrationTB(filename))
  end
end

M.setup = function(themes_cb)
  -- override custom colors keymapping:
  vim.keymap.set("n", "<leader>uu", function() select(themes_cb) end, { desc = "Base46 colors" })
  load_all_highlights()
end

return M
