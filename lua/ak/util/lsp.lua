--          ╭─────────────────────────────────────────────────────────╮
--          │        Method on_attach is used in various files        │
--          ╰─────────────────────────────────────────────────────────╯

---@class ak.util.lsp
local M = {}

---@param on_attach fun(client, buffer)
function M.on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf ---@type number
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then on_attach(client, buffer) end
    end,
  })
end

return M
