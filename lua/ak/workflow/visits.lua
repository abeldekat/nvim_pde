require("akmini.visits_harpooned").setup()

local map = function(mode, lhs, rhs, opts)
  if lhs == "" then return end
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

map("n", "<leader>j", VisitsHarpooned.pick_from_all, { desc = "Visits pick all" })
map("n", "<leader>a", VisitsHarpooned.toggle, { desc = "Visits toggle" })
local selects = { "<c-j>", "<c-k>", "<c-l>", "<c-h>" }
for i = 1, #selects do
  map("n", selects[i], function() VisitsHarpooned.select(i) end, { desc = "Visit " .. i })
end
map("n", "<leader>ol", VisitsHarpooned.pick_from_current, { desc = "Visits pick" })
map("n", "<leader>oj", VisitsHarpooned.switch_label, { desc = "Visits switch label" })
map("n", "<leader>oa", VisitsHarpooned.new_label, { desc = "Visits new label" })
map("n", "<leader>om", VisitsHarpooned.maintain, { desc = "Visits maintain" })
map("n", "<leader>or", VisitsHarpooned.clear_all_visits, { desc = "Visits clear all" })
