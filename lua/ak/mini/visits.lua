require("akextra.visits_harpooned").setup() -- customized visits

require("akextra.harpoonline").setup({
  on_produce = function() vim.wo.statusline = "%{%v:lua.MiniStatusline.active()%}" end,
  highlight_active = function(text) -- optionally highlight active buffer
    return string.format("%%#%s# %s %%#%s#", "MiniHipatternsHack", text, "MiniStatuslineDevinfo")
  end,
}, VisitsHarpooned.as_provider())
