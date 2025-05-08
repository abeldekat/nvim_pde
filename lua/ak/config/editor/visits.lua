local VisitsHarpooned = require("ak.mini.visits_harpooned")
VisitsHarpooned.setup({
  keys = {
    selects = { "<c-j>", "<c-k>", "<c-l>", "<c-h>" },
  },
  picker_hints_on_switch_label = { "j", "k", "l", "h" },
})
