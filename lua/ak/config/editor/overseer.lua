vim.keymap.set("n", "<leader>sl", function() end, { desc = "No-op overseer", silent = true })

local keys = { -- LazyVim: leader o, already used for "other"
  { "<leader>sw", "<cmd>OverseerToggle<cr>", "Task list" },
  { "<leader>so", "<cmd>OverseerRun<cr>", "Run task" },
  { "<leader>sq", "<cmd>OverseerQuickAction<cr>", "Action recent task" },
  { "<leader>si", "<cmd>OverseerInfo<cr>", "Overseer Info" },
  { "<leader>sb", "<cmd>OverseerBuild<cr>", "Task builder" },
  { "<leader>st", "<cmd>OverseerTaskAction<cr>", "Task action" },
  { "<leader>sc", "<cmd>OverseerClearCache<cr>", "Clear cache" },
}

for _, key in ipairs(keys) do
  vim.keymap.set("n", key[1], key[2], { desc = key[3], silent = true })
end

require("overseer").setup({
  -- dap = false,
  -- task_list = {
  --   bindings = {
  --     ["<C-h>"] = false,
  --     ["<C-j>"] = false,
  --     ["<C-k>"] = false,
  --     ["<C-l>"] = false,
  --   },
  -- },
})
