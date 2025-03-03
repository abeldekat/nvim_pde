local VisitsHarpooned = require("ak.mini.visits_harpooned")
VisitsHarpooned.setup({
  labels = { "core", "side", "oth", "glo" },
  mappings = {
    selects = { "<c-j>", "<c-k>", "<c-l>", "<c-h>" },
  },
  picker_hints_on_change_active_label = { "j", "k", "l", "h" },
})
