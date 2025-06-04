---@type vim.diagnostic.Opts
vim.diagnostic.config({
  underline = false,
  signs = { -- show gutter sings
    priority = 9999, -- with highest priority
    severity = { min = "WARN", max = "ERROR" }, -- only warnings and errors
  },
  virtual_text = { severity = { min = "ERROR", max = "ERROR" } },
  -- virtual_lines = { current_line = true }, -- pretty but too jumpy...
  update_in_insert = false, -- don't update diagnostics when typing
})
