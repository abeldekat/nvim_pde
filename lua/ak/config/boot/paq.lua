--          ╭─────────────────────────────────────────────────────────╮
--          │                      Experimental                       │
--          ╰─────────────────────────────────────────────────────────╯

local function clone_paq()
  local path = vim.fn.stdpath("data") .. "/site/pack/paqs/start/paq-nvim"
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
  if not is_installed then
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/savq/paq-nvim.git", path })
    vim.cmd.packadd("paq-nvim")
    return true
  end
end

--          ╭─────────────────────────────────────────────────────────╮
--          │            https://github.com/savq/paq-nvim             │
--          ╰─────────────────────────────────────────────────────────╯
local modules = {
  require("ak.paq.start"),
}
return function(_, _) -- extraspec, opts
  local is_first_install = clone_paq()
  local paq = require("paq")

  -- read the spec
  local packages = { "savq/paq-nvim" }
  for _, module in ipairs(modules) do
    vim.list_extend(packages, module.spec())
  end
  paq(packages)

  -- automatic install when headless or when starting from scratch
  if #vim.api.nvim_list_uis() == 0 then
    vim.cmd("autocmd User PaqDoneInstall quit")
    paq.install() -- headless install quit when done
  elseif is_first_install then
    vim.notify("Installing plugins... If prompted, hit Enter to continue.")
    paq.install()
  end

  -- setup the modules
  for _, module in ipairs(modules) do
    module.setup()
  end
end
