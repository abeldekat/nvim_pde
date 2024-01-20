local M = {}

function M.should_load()
  -- don't start when opening a file
  if vim.fn.argc() > 0 then
    return false
  end
  -- ... more logic here
  return true
end

function M.setup()
  local has_lazy, lazy = pcall(require, "lazy")
  local opts = {
    theme = "doom",
    hide = {
      -- this is taken care of by lualine
      -- enabling this messes up the actual laststatus setting after loading a file
      statusline = false,
    },
    config = {
      center = {
        {
          action = "Telescope git_files",
          desc = " Files(git) [leader leader]",
          icon = " ",
          key = "g",
        },
        {
          action = "Telescope find_files",
          desc = " Files [leader s f]",
          icon = " ",
          key = "f",
        },
        {
          action = "Telescope oldfiles",
          desc = " Recent [leader r]",
          icon = " ",
          key = "r",
        },
        {
          action = "Telescope keymaps",
          desc = " Keymaps [leader s k]",
          icon = " ",
          key = "y",
        },
        {
          action = "Telescope live_grep",
          desc = " Text [leader e]",
          icon = " ",
          key = "e",
        },
        {
          action = "lua vim.api.nvim_input('mk')",
          desc = " Oil [mk]",
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
  if has_lazy then
    table.insert(opts.config.center, {
      action = "Lazy",
      desc = " Lazy",
      icon = "󰒲 ",
      key = "l",
    })
    opts.config.footer = function()
      local stats = lazy.stats()
      local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
      return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
    end
  else
    opts.config.footer = function()
      return {}
    end
  end

  for _, button in ipairs(opts.config.center) do
    button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
    button.key_format = "  %s"
  end

  -- close Lazy and re-open when the dashboard is ready
  if vim.o.filetype == "lazy" then
    vim.cmd.close()
    vim.api.nvim_create_autocmd("User", {
      pattern = "DashboardLoaded",
      callback = function()
        require("lazy").show()
      end,
    })
  end

  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ""
  local minor = versioninfo.minor or ""
  local patch = versioninfo.patch or ""
  local prerelease = versioninfo.api_prerelease and "-dev" or ""
  local version = string.format("NVIM v%s.%s.%s%s", major, minor, patch, prerelease)
  local logo = [[ ]]

  logo = string.rep("\n", 8) .. logo .. "\n\n"
  local header = vim.split(logo, "\n")
  header[8] = version
  opts.config.header = header

  require("dashboard").setup(opts)
end

return M
