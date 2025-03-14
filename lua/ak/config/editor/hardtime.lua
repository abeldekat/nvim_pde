-- Replace takac/vim-hardtime with m4xshen/hardtime.nvim:
-- :Hardtime report -> has nui plugin dependency.
-- Copy the code(hardtime.report.lua) and use vim.notify instead:
local report = function()
  -- In .local/state/nvim:
  local file_path = vim.api.nvim_call_function("stdpath", { "log" }) .. "/hardtime.nvim.log"
  local file = io.open(file_path, "r")
  if file == nil then
    vim.notify("No hardtime messages.", vim.log.levels.INFO) -- Not an error...
    return
  end

  local hints = {}
  for line in file:lines() do
    local hint = string.gsub(line, "%[.-%] ", "")
    hints[hint] = hints[hint] and hints[hint] + 1 or 1
  end
  file:close()

  local sorted_hints = {}
  for hint, count in pairs(hints) do
    table.insert(sorted_hints, { hint, count })
  end
  if vim.tbl_isempty(sorted_hints) then
    vim.notify("No hardtime messages", vim.log.levels.INFO)
    return
  end

  -- There are messages:
  table.sort(sorted_hints, function(a, b) return a[2] > b[2] end)
  local hints_iter = vim
    .iter(ipairs(sorted_hints))
    :map(function(i, v) return string.format("%d. %s (%d times)", i, v[1], v[2]) end)
  vim.notify("\n" .. table.concat(hints_iter:totable(), "\n"), vim.log.levels.INFO)
end

require("hardtime").setup()
vim.keymap.set("n", "<leader>uh", "<cmd>Hardtime toggle<cr>", { desc = "Toggle hardime", silent = true })
vim.keymap.set("n", "<leader>oh", report, { desc = "Report hardime", silent = true })
