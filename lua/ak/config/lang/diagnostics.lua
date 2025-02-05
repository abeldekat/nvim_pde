local icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

---@type vim.diagnostic.Opts
local opts = {
  -- underline = true,
  update_in_insert = false,
  float = { border = "double" },

  virtual_text = {
    -- Show virtual text only for errors
    severity = { min = "ERROR", max = "ERROR" },
    spacing = 4,
    source = "if_many",
    prefix = function(diagnostic)
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then return icon end
      end
      return "●"
    end,
  },

  -- severity_sort = true,
  signs = { -- show gutter signs
    text = {
      [vim.diagnostic.severity.ERROR] = icons.Error,
      [vim.diagnostic.severity.WARN] = icons.Warn,
      [vim.diagnostic.severity.HINT] = icons.Hint,
      [vim.diagnostic.severity.INFO] = icons.Info,
    },
    -- With highest priority
    priority = 9999,
    -- Only for warnings and errors
    severity = { min = "WARN", max = "ERROR" },
  },
}
vim.diagnostic.config(vim.deepcopy(opts))
