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
      [vim.diagnostic.severity.ERROR] = Consts.icons.diagnostics.Error,
      [vim.diagnostic.severity.WARN] = Consts.icons.diagnostics.Warn,
      [vim.diagnostic.severity.HINT] = Consts.icons.diagnostics.Hint,
      [vim.diagnostic.severity.INFO] = Consts.icons.diagnostics.Info,
    },
  },
}

if vim.fn.has("nvim-0.10.0") == 0 then -- Don't define diagnostics signs on >= 0.10:
  for severity, icon in pairs(opts.signs.text) do
    local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
    name = "DiagnosticSign" .. name
    vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
  end
end

vim.diagnostic.config(vim.deepcopy(opts))
