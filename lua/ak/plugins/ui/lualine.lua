return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = " "
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  config = function()
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
  end,
}
