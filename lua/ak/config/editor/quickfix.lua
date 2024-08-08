local M = {}

M.bqf = function()
  require("pqf").setup({
    show_multiple_lines = true,
    max_filename_length = 40,
  })
  -- Press <Tab> or <S-Tab> to toggle the sign of item
  -- Press zn or zN will create new quickfix list
  -- Press zf in quickfix window will enter fzf mode --> use quickfix from picker instead
  -- Press o, open the item, and close quickfix window
  require("bqf").setup({
    func_map = { split = "<C-s>" },
  })
end

-- Feature: Editing the quickfix like a normal buffer
-- Preview not as strong as bqf
-- bqf has the o key which also closes the list
-- :help quickfixtextfunc
M.quicker = function()
  -- Override leader x defined in keymaps
  vim.keymap.set("n", "<leader>x", function() require("quicker").toggle() end, {
    desc = "Toggle quickfix",
  })
  -- For now: No need for loclist toggle
  -- vim.keymap.set("n", "<leader>l", function() require("quicker").toggle({ loclist = true }) end, {
  --   desc = "Toggle loclist",
  -- })

  local expand = function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end
  local collapse = function() require("quicker").collapse() end

  ---@module "quicker"
  ---@type quicker.SetupOptions
  local opts = {
    keys = {
      { ">", expand, desc = "Expand quickfix context" },
      { "<", collapse, desc = "Collapse quickfix context" },
    },
  }
  require("quicker").setup(opts)
end

return M
