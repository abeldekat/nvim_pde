local Util = require("ak.util")

local function clone_paq()
  local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
  if not is_installed then
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path })
    vim.cmd.packadd("paq-nvim")
    return true
  end
end

local modules = {
  require("ak.paq.start"), -- responsible for options, keys, autocmds and colorscheme
  require("ak.paq.coding"),
  require("ak.paq.colors"),
  require("ak.paq.editor"),
  require("ak.paq.treesitter"),
  require("ak.paq.ui"),
  require("ak.paq.util"),
  --
  require("ak.paq.lang.formatting"),
  require("ak.paq.lang.linting"),
  require("ak.paq.lang.lsp"),
  require("ak.paq.lang.testing"),
  require("ak.paq.lang.debugging"),
  require("ak.paq.lang.extra"),
}

local function read_spec()
  local packages = {}
  for _, module in ipairs(modules) do
    vim.list_extend(packages, module.spec())
  end
  return packages
end

-- make sure the config for all plugins in the module is loaded
local function setup_modules()
  Util.register_referenced({ "trouble.nvim", "flash.nvim", "eyeliner.nvim", "nvim-dap-python" })
  for _, module in ipairs(modules) do
    module.setup()
  end
end

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

-- NOTE: Headless: nvim --headless -u NONE -c 'lua require("ak.config.boot.paq")()'
return function(_, _) -- extraspec, opts
  setup_performance()
  local is_first_install = clone_paq()
  local paq = require("paq")
  paq(read_spec())

  if #vim.api.nvim_list_uis() == 0 then -- install when headless:
    vim.cmd("autocmd User PaqDoneInstall quit") -- quit when done
    paq.install()
    return
  end

  if is_first_install then -- install from scratch
    Util.info("Installing plugins... If prompted, hit Enter to continue.")
    paq.install()
    vim.api.nvim_create_autocmd("User", {
      pattern = "PaqDoneInstall",
      callback = setup_modules, -- continue when done
    })
    return
  end

  setup_modules()
end
