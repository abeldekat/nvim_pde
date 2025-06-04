local DeferredDeps = require("akmini.deps_deferred")
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

later(function()
  -- Removed "dstein64/vim-startuptime"
  -- Use an alias, like: vs='touch vimreport.out && rm vimreport.out && nvim --startuptime vimreport.out'

  local spec_slime = { source = "jpalardy/vim-slime" }
  DeferredDeps.register(spec_slime)
  DeferredDeps.on_keys(function()
    now(function()
      require("ak.other.slime")
      add(spec_slime)
      vim.notify("Loaded vim-slime", vim.log.levels.INFO)
    end)
  end, "<leader>oR", "Load slime(repl)")

  -- ...on_keys(function() .. other.doc ... "<leader>oD", "Mini doc"
end)
