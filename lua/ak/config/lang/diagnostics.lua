local Consts = require("ak.consts")

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
      local icons = require("ak.consts").icons.diagnostics
      for d, icon in pairs(icons) do
        if diagnostic.severity == vim.diagnostic.severity[d:upper()] then return icon end
      end
      return "●"
    end,
  },
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = Consts.icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = Consts.icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = Consts.icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = Consts.icons.diagnostics.Info,
    },
  },
}
vim.diagnostic.config(vim.deepcopy(opts))
