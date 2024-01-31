local Util = require("ak.util")

local function setup_performance()
  -- tohtml.vim             0.06    0.06
  -- syntax.vim             0.27    0.26 ▏

  -- TODO: More plugins to disable?
  -- disabled_plugins = { "tohtml", "tutor" },
  --
  for _, disable in ipairs({ "gzip", "netrwPlugin", "tarPlugin", "zipPlugin" }) do
    vim.g["loaded_" .. disable] = 0
  end
end

local modules = {
  "ak.submodules.start",
  "ak.submodules.coding",
  "ak.submodules.editor",
  "ak.submodules.treesitter",
  "ak.submodules.ui",
  "ak.submodules.util",
  "ak.submodules.lang.formatting",
  "ak.submodules.lang.linting",
  "ak.submodules.lang.lsp",
  "ak.submodules.lang.testing",
  "ak.submodules.lang.debugging",
  "ak.submodules.lang.extra",
}

return function(_, _) -- extraspec, opts
  setup_performance()

  -- When using submodules, lualine overriding behaves differently,
  -- because both the override and the lualine plugin are in the config folder
  -- See: lualine.utils.loader.lua, function load_theme, line 232
  --
  local lualine_override = vim.fn.stdpath("config") .. "/lualine_themes"
  vim.opt.rtp:append(lualine_override)

  -- flash: Defined in coding, also used in editor, for telescope
  -- eyeliner: Defined in coding, also used in treesitter, for textobjects
  -- trouble: Defined in editor, also used in lang.testing, for neotest
  -- nvim-dap-python: Defined in dap, also used in lang.python, for venv-selector
  Util.register_referenced({ "trouble.nvim", "flash.nvim", "eyeliner.nvim", "nvim-dap-python" })

  for _, module in ipairs(modules) do
    require(module)
  end
end
