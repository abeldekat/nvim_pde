local Util = require("ak.util")
local add, later = vim.cmd.packadd, Util.defer.later

if Util.submodules.is_provisioning() then
  Util.submodules.print_provision("lsp")

  -- Before any packages can be used, the registry needs to be downloaded
  -- Is also invoked on mason's commands and on opening the ui
  add("mason.nvim")
  require("mason").setup()
  vim.cmd("MasonUpdate")

  return
end

local function load()
  add("mason.nvim")
  require("ak.config.lang.mason")

  add("neoconf.nvim")
  add("neodev.nvim")
  add("mason-lspconfig.nvim")
  add("nvim-lspconfig")
  require("ak.config.lang.lspconfig")

  add("SchemaStore.nvim")

  add("fidget.nvim")
  require("ak.config.lang.fidget")

  -- The lsp does not attach when directly opening a file:
  if not (Util.opened_without_arguments() or Util.opened_with_dir_argument()) then
    vim.cmd("LspStart") --
  end
end

later(load)
