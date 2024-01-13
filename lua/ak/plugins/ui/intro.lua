return {
  "nvimdev/dashboard-nvim",
  event = function() -- vimenter
    local should_load = function()
      -- don't start when opening a file
      if vim.fn.argc() > 0 then
        return false
      end
      -- ... more logic here
      return true
    end

    if should_load() then
      return { "VimEnter" }
    else
      return {}
    end
  end,
  config = function()
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
            action = "Telescope find_files",
            desc = " Find file",
            icon = " ",
            key = "f",
          },
          {
            action = "ene | startinsert",
            desc = " New file",
            icon = " ",
            key = "n",
          },
          {
            action = "Telescope oldfiles",
            desc = " Recent files",
            icon = " ",
            key = "r",
          },
          {
            action = "Telescope live_grep",
            desc = " Find text",
            icon = " ",
            key = "g",
          },
          {
            action = [[lua require("ak.util").telescope.config_files()()]],
            desc = " Config",
            icon = " ",
            key = "c",
          },
          {
            action = 'lua require("persistence").load()',
            desc = " Restore Session",
            icon = " ",
            key = "s",
          },
          {
            action = "Lazy",
            desc = " Lazy",
            icon = "󰒲 ",
            key = "l",
          },
          {
            action = "qa",
            desc = " Quit",
            icon = " ",
            key = "q",
          },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

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

    -- local project = {
    --   action = "Telescope project",
    --   desc = " Projects",
    --   icon = " ",
    --   key = "p",
    -- }
    -- project.desc = project.desc .. string.rep(" ", 43 - #project.desc)
    -- project.key_format = "  %s"
    -- table.insert(opts.config.center, 3, project)

    require("dashboard").setup(opts)
  end,
}
