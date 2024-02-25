--          ╭─────────────────────────────────────────────────────────╮
--          │           DEPRECATED in favor of mini.starter           │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │                       ak.deps.ui:                       │
--          ╰─────────────────────────────────────────────────────────╯
-- now(function()
--   if Util.opened_without_arguments() then -- dashboard loads on UIEnter...
--     add("nvimdev/dashboard-nvim")
--     require("ak.config.ui.dashboard").setup({
--       {
--         action = "DepsUpdate",
--         desc = " Update",
--         icon = "",
--         key = "u",
--       },
--       {
--         action = "DepsSnapSave",
--         desc = " SnapSave",
--         icon = "",
--         key = "U",
--       },
--     }, function() return { "Press space for the menu" } end)
--   else
--     later(function() register("nvimdev/dashboard-nvim") end)
--   end
-- end)

--          ╭─────────────────────────────────────────────────────────╮
--          │                    ak.submodules.ui:                    │
--          ╰─────────────────────────────────────────────────────────╯
-- if Util.opened_without_arguments() then -- dashboard loads on UIEnter...
--   add("dashboard-nvim")
--   require("ak.config.ui.dashboard").setup({}, function() return { "Press space for the menu" } end)
-- end

--          ╭─────────────────────────────────────────────────────────╮
--          │                       ak.lazy.ui:                       │
--          ╰─────────────────────────────────────────────────────────╯
-- {
--   "nvimdev/dashboard-nvim",
--   event = function() return Util.opened_without_arguments() and "VimEnter" or {} end,
--   config = function()
--     require("ak.config.ui.dashboard").setup({
--       {
--         action = "Lazy",
--         desc = " Lazy",
--         icon = "󰒲 ",
--         key = "l",
--       },
--     }, function()
--       local stats = require("lazy").stats()
--       local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
--       return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
--     end)
--   end,
-- },
local M = {}

local function make_header()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  local prerelease = versioninfo.api_prerelease and "-dev" or ""

  local header = vim.split(string.rep("\n", 10), "\n")
  header[8] = string.format("NVIM v%s.%s.%s%s", major, minor, patch, prerelease)
  return header
end

local function format_center(opts)
  for _, button in ipairs(opts.config.center) do
    button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
    button.key_format = "  %s"
  end
end

local function get_opts()
  local opts = {
    theme = "doom",
    hide = { statusline = false },
    config = {
      header = make_header(),
      center = {
        {
          action = "Telescope git_files show_untracked=true",
          desc = " Gitfiles     ( space space )",
          icon = " ",
          key = "f",
        },
        {
          action = "Telescope find_files",
          desc = " Files        ( space f f )",
          icon = " ",
          key = "F",
        },
        {
          action = "Telescope oldfiles",
          desc = " Recent       ( space r )",
          icon = " ",
          key = "r",
        },
        {
          action = "Telescope live_grep",
          desc = " Text         ( space e )",
          icon = " ",
          key = "e",
        },
        {
          action = "lua vim.api.nvim_input('mk')",
          desc = " Oil          ( mk )",
          icon = " ",
          key = "o",
        },
        -- {
        --   action = 'lua require("persistence").load()',
        --   desc = " Restore Session",
        --   icon = " ",
        --   key = "s",
        -- },
        {
          action = "qa",
          desc = " Quit",
          icon = " ",
          key = "q",
        },
      },
    },
  }

  return opts
end

function M.setup(extra_center, footer_cb)
  local opts = get_opts()

  vim.list_extend(opts.config.center, extra_center or {})
  format_center(opts)

  opts.config.footer = footer_cb -- important: evaluated on UIEnter
  require("dashboard").setup(opts)
end

return M
