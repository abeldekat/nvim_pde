-- cmd = { "TroubleToggle", "Trouble" },
require("trouble").setup({ use_diagnostic_signs = true })

local key = vim.keymap.set
key(
  "n",
  "<leader>xx",
  "<cmd>TroubleToggle document_diagnostics<cr>",
  { desc = "Document diagnostics (trouble)", silent = true }
)
key(
  "n",
  "<leader>xX",
  "<cmd>TroubleToggle workspace_diagnostics<cr>",
  { desc = "Workspace diagnostics (trouble)", silent = true }
)
key("n", "<leader>xL", "<cmd>TroubleToggle loclist<cr>", { desc = "Location list (trouble)", silent = true })
key("n", "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", { desc = "Quickfix list (trouble)", silent = true })
key("n", "[q", function()
  if require("trouble").is_open() then
    require("trouble").previous({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Previous trouble/quickfix item", silent = true })
key("n", "]q", function()
  if require("trouble").is_open() then
    require("trouble").next({ skip_groups = true, jump = true })
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end, { desc = "Next trouble/quickfix item", silent = true })
