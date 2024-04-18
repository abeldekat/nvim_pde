return {
  {
    "dstein64/vim-startuptime",
    keys = { { "<leader>ms", desc = "Startuptime" } },
    config = function() require("ak.config.util.startuptime") end,
  },

  {
    "jpalardy/vim-slime",
    keys = { { "<leader>mr", desc = "Repl" } },
    config = function() require("ak.config.util.slime") end,
  },

  {
    "danymat/neogen",
    --          ╭─────────────────────────────────────────────────────────╮
    --          │             Efficiency: Also setup mini.doc             │
    --          ╰─────────────────────────────────────────────────────────╯
    keys = { { "<leader>ms", desc = "Document" }, { "<leader>md", desc = "Generate plugin doc" } },
    config = function()
      require("ak.config.util.neogen")
      require("ak.config.util.mini_doc")
    end,
  },
}
