--      ╭────────────────────────────────────────────────────────────────╮
--      │https://gist.github.com/siduck/cc7305db586d512b5fd3f4ea73c9cc81 │
--      │                    https://0x0.st/Xrbn.mp4                     │
--      ╰────────────────────────────────────────────────────────────────╯

-- The collection in plugin nvchad/base46 has around 70 themes
-- The plugin requires lua/nvconfig: Require returns this module instead.
-- M.ui and M.base46 are stripped down parts of nvconfig.
--
-- The base46 plugin itself is needed on initial install, on update and on theme change

-- Activate the collection: Set local color = "base46" in ak.colors.lua,
-- In order to switch back to regular themes, undo the above and restart nvim.
-- Only use this collection **after** plugin base64 has been installed!

local M = {}

M.ui = { --  transparency = false, theme_toggle = {},
  theme = "melange",
  changed_themes = {},
  hl_override = {},
  hl_add = {
    MiniStatuslineFilename = { bg = "statusline_bg", fg = "grey_fg2" },
    MiniStatuslineModeNormal = { bg = "statusline_bg", fg = "grey_fg2", bold = true },
    MiniStatuslineModeInsert = { bg = "green", fg = "black", bold = true },
    MiniStatuslineModeReplace = { bg = "red", fg = "black", bold = true },
    MiniStatuslineModeCommand = { bg = "yellow", fg = "black", bold = true },
    MiniStatuslineModeOther = { bg = "blue", fg = "black", bold = true },
    MiniStatuslineModeVisual = { bg = "dark_purple", fg = "black", bold = true },
    MiniHipatternsFixme = { bg = "red", fg = "black", bold = true },
    MiniHipatternsHack = { bg = "yellow", fg = "black", bold = true },
    MiniHipatternsTodo = { bg = "blue", fg = "black", bold = true },
    MiniHipatternsNote = { bg = "green", fg = "black", bold = true },
    StatusLine = { bg = "statusline_bg" }, -- part of statusline integration
  },

  -- Removed integrations cheatsheet, nvdash, statusline, tabufline, telescope and term:
  cmp = { icons = true, lspkind_text = true, style = "default" },
  lsp = { signature = true },
}
M.base46 = { integrations = {} } -- Dummy, used in plugin base46.init.lua

--          ╭─────────────────────────────────────────────────────────╮
--          │                         Added:                          │
--          ╰─────────────────────────────────────────────────────────╯

vim.g.base46_cache = vim.fn.stdpath("data") .. "/nvchad/base46/"
local integrations = { --  "statusline", "devicons", "telescope",
  "blankline",
  "cmp",
  "defaults",
  "git",
  "lsp",
  "mason",
  "syntax",
  "treesitter",
}

-- Override base46.load_all_highlights to only load selected integrations
local function load_all_highlights()
  for _, filename in ipairs(integrations) do
    dofile(vim.g.base46_cache .. filename)
  end
end

local function persist(old, new)
  local this_module = vim.fn.stdpath("config") .. "/lua/ak/config/colors/" .. "base46.lua"
  local file = io.open(this_module, "r")
  if not file then return end

  local added_pattern = string.gsub(old, "-", "%%-") -- add % before - if exists
  local new_content = file:read("*all"):gsub(added_pattern, new)

  file = io.open(this_module, "w")
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
  vim.ui.select(default_themes, { prompt = "Select base46" }, function(choice)
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
  local require_orig = require -- return this module when nvconfig is required
  _G.require = function(args)
    if type(args) == "string" and args == "nvconfig" then return require_orig("ak.config.colors.base46") end
    return require_orig(args)
  end
  if not vim.loop.fs_stat(vim.g.base46_cache) then vim.fn.mkdir(vim.g.base46_cache, "p") end

  local base46 = require("base46")
  for _, filename in ipairs(integrations) do
    base46.saveStr_to_cache(filename, base46.load_integrationTB(filename))
  end
  _G.require = require_orig -- restore require
end

M.setup = function(themes_cb)
  -- override custom colors keymapping:
  vim.keymap.set("n", "<leader>uu", function() select(themes_cb) end, { desc = "Base46 colors" })
  load_all_highlights()
end

return M
