local opts = {
  options = {
    icons_enabled = false,
    globalstatus = true,
    component_separators = "|",
    section_separators = "",
    disabled_filetypes = { statusline = { "dashboard" } },
  },
  sections = {
    lualine_c = {
      { "filename", path = 1, shortening_target = 40, symbols = { unnamed = "" } },
    },
  },
}
require("lualine").setup(opts)
