local function map(l, r, opts, mode)
  mode = mode or "n"
  opts["silent"] = opts.silent ~= false
  opts["noremap"] = true
  vim.keymap.set(mode, l, r, opts)
end

-- Titles
map("<leader>bb", function()
  ---@diagnostic disable-next-line: missing-parameter
  require("comment-box").ccbox() -- a centered fixed size box with the text centered
end, { desc = "Commentbox box" }, "v") -- , { "n", "v" })

-- Line
-- map("<leader>Cl", "<cmd>CBllline<cr>", { desc = "Commentbox titled line" }, "v") -- , { "n", "v" })
map("<leader>bl", function()
  ---@diagnostic disable-next-line: missing-parameter
  require("comment-box").llline() -- left aligned titled line with left aligned text
end, { desc = "Commentbox titled line" }, "v") -- , { "n", "v" })
