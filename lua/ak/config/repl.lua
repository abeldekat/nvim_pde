local M = {}

function M.init()
  vim.g.slime_target = "neovim"
end

-- Find neovim terminal job id: echo &channel
-- After repl starts: use <c-c><c-c>
function M.setup()
  vim.keymap.set("n", "<leader>mr", "<cmd>echom &channel<cr>", { desc = "Repl", silent = true })
end

return M
