--          ╭─────────────────────────────────────────────────────────╮
--          │              Adapted LazyVim util lazygit               │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

---@class ak.util.color_lazygit
local M = setmetatable({}, {
  __call = function(m, ...) return m.update_if_needed(...) end,
})

local theme = {
  [241] = { fg = "Special" },
  activeBorderColor = { fg = "MatchParen", bold = true },
  cherryPickedCommitBgColor = { fg = "Identifier" },
  cherryPickedCommitFgColor = { fg = "Function" },
  defaultFgColor = { fg = "Normal" },
  inactiveBorderColor = { fg = "FloatBorder" },
  optionsTextColor = { fg = "Function" },
  searchingActiveBorderColor = { fg = "MatchParen", bold = true },
  selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
  unstagedChangesColor = { fg = "DiagnosticError" },
}

local theme_path = vim.fn.stdpath("cache") .. "/lazygit-theme.yml"

local xdg_config = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
local config_dir = xdg_config .. "/lazygit"
vim.env.LG_CONFIG_FILE = config_dir .. "/config.yml" .. "," .. theme_path

local dirty = true -- re-create config file on startup

local function write_file(file, contents)
  local fd = assert(io.open(file, "w+"))
  fd:write(contents)
  fd:close()
end

local function set_ansi_color(idx, color) io.write(("\27]4;%d;%s\7"):format(idx, color)) end

local function get_color(v)
  ---@type string[]
  local color = {}
  if v.fg then
    color[1] = Util.color.color_hl(v.fg)
  elseif v.bg then
    color[1] = Util.color.color_hl(v.bg, true)
  end
  if v.bold then table.insert(color, "bold") end
  return color
end

local function update_config()
  local updated_theme = {}

  for k, v in pairs(theme) do
    if type(k) == "number" then
      local color = get_color(v)
      -- LazyGit uses color 241 a lot, so also set it to a nice color
      -- pcall, since some terminals don't like this
      pcall(set_ansi_color, k, color[1])
    else
      updated_theme[k] = get_color(v)
    end
  end

  local config = [[
os:
  editPreset: "nvim-remote"
gui:
  nerdFontsVersion: 3
  theme:
]]

  ---@type string[]
  local lines = {}
  for k, v in pairs(updated_theme) do
    lines[#lines + 1] = ("   %s:"):format(k)
    for _, c in ipairs(v) do
      lines[#lines + 1] = ("     - %q"):format(c)
    end
  end
  config = config .. table.concat(lines, "\n")
  write_file(theme_path, config)
  M.dirty = false
end

-- re-create theme file on ColorScheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() dirty = true end,
})

-- https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md#overriding-default-config-file-location
function M.update_if_needed()
  if dirty then update_config() end
end

return M
