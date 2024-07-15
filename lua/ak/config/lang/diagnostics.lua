local icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

---@type vim.diagnostic.Opts
local opts = {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    -- Show virtual text only for errors
    -- severity = { min = "ERROR", max = "ERROR" },

    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then return icon end
      end
      return "●"
    end,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.Error,
      [vim.diagnostic.severity.WARN] = icons.Warn,
      [vim.diagnostic.severity.HINT] = icons.Hint,
      [vim.diagnostic.severity.INFO] = icons.Info,
    },
  },
}
vim.diagnostic.config(vim.deepcopy(opts))
