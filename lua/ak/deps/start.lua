local MiniDeps = require("mini.deps")
local Util = require("ak.util")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

now(function()
  require("ak.config.options")
  require("ak.config.autocmds")
  require("ak.config.mini_misc") -- ie last cursor position autocmd
end)

local function icons() require("ak.config.mini_icons") end -- cmp, oil etc...
-- stylua: ignore 
if Util.opened_with_dir_argument() then now(icons) else later(icons) end

later(function()
  require("ak.config.keymaps")

  add("nvim-lua/plenary.nvim")
  require("ak.config.mini_extra") -- pickers and ai
  require("ak.config.mini_notify") -- better installation process
end)
