local function header_cb()
  local versioninfo = vim.version() or {}
  local major = versioninfo.major or ''
  local minor = versioninfo.minor or ''
  local patch = versioninfo.patch or ''
  return string.format('NVIM v%s.%s.%s', major, minor, patch)
end

local starter = require('mini.starter')
starter.setup({
  header = header_cb,
  items = {
    starter.sections.sessions(5, true),
    starter.sections.recent_files(4, true, false),
    starter.sections.builtin_actions(),
    {
      { action = 'lua vim.pack.update()', name = 'Update plugins', section = 'Updaters' },
    },
  },
  footer = function() return '  Press space for the menu' end,
})
