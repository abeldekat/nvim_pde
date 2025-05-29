-- Other...
local Util = require("ak.util")
local MiniDeps = require("mini.deps")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local register = Util.deps.register

later(function()
  -- Removed "dstein64/vim-startuptime"
  -- Use an alias, like: vs='touch vimreport.out && rm vimreport.out && nvim --startuptime vimreport.out'

  local spec_slime = { source = "jpalardy/vim-slime" }
  register(spec_slime)
  Util.defer.on_keys(function()
    now(function()
      require("ak.config.other.slime")
      add(spec_slime)
      vim.notify("Loaded vim-slime", vim.log.levels.INFO)
    end)
  end, "<leader>oR", "Load slime(repl)")

  -- Util.defer.on_keys(function()
  --   now(function() require("ak.config.other.doc") end)
  -- end, "<leader>oD", "Mini doc")
end)
