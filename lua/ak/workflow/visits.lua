require("akmini.visits_harpooned").setup()

local map = function(mode, lhs, rhs, opts)
  if lhs == "" then return end
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

local add_selects = function(selects)
  for i = 1, #selects do
    map("n", selects[i], function() VisitsHarpooned.select(i) end, { desc = "Visit " .. i })
  end
end

map("n", "<leader>n", VisitsHarpooned.pick_from_current, { desc = "Visits pick" })
map("n", "<leader>a", VisitsHarpooned.toggle, { desc = "Visits toggle" })
add_selects({ "<leader>4", "<leader>5", "<leader>6", "<leader>1" })

-- ctrl jklh is not easy with the colemak-dh layout...
-- c-n is in use for half page down...
map("n", "<c-p>", VisitsHarpooned.forward, { desc = "Visits next wrap" })

map("n", "<leader>on", VisitsHarpooned.pick_from_all, { desc = "Visits pick all" })
map("n", "<leader>ol", VisitsHarpooned.switch_label, { desc = "Visits switch label" })
map("n", "<leader>oa", VisitsHarpooned.new_label, { desc = "Visits new label" })
map("n", "<leader>om", VisitsHarpooned.maintain, { desc = "Visits maintain" })
map("n", "<leader>or", VisitsHarpooned.clear_all_visits, { desc = "Visits clear all" })
