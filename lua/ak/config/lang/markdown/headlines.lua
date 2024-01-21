local opts = {}
for _, ft in ipairs({ "markdown", "norg", "rmd", "org" }) do
  opts[ft] = {
    headline_highlights = {},
  }
  for i = 1, 6 do
    local hl = "Headline" .. i
    vim.api.nvim_set_hl(0, hl, { link = "Headline", default = true })
    table.insert(opts[ft].headline_highlights, hl)
  end
end
opts.markdown = {
  -- https://github.com/lukas-reineke/headlines.nvim/issues/41#issuecomment-1556334775
  fat_headline_lower_string = "▔",
}

vim.schedule(function() -- performance, schedule
  require("headlines").setup(opts)
  require("headlines").refresh()
end)
