for name, icon in pairs(require("ak.consts").icons.diagnostics) do
  name = "DiagnosticSign" .. name
  vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end

local opts = {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    -- Show virtual text only for errors
    -- severity = { min = "ERROR", max = "ERROR" }, -- TODO: Test this

    spacing = 4,
    source = "if_many",
    -- prefix = "●",
    -- this will set the prefix to a function returning the diagnostics icon based on the severity
    -- , only on a recent 0.10.0 build. Will be set to "●" when not supported
    prefix = vim.fn.has("nvim-0.10.0") == 0 and "●" or function(diagnostic)
      local icons = require("ak.consts").icons.diagnostics
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then return icon end
      end
    end,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = require("ak.consts").icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = require("ak.consts").icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = require("ak.consts").icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = require("ak.consts").icons.diagnostics.Info,
    },
  },
}

vim.diagnostic.config(vim.deepcopy(opts))
