-- https://github.com/astral-sh/ruff/
-- Arch linux: sudo pacman -S ruff

local desc = "Organize imports"
local opts_code_action = {
  apply = true,
  context = { only = { "source.organizeImports" }, diagnostics = {} },
}
local code_action = function() vim.lsp.buf.code_action(opts_code_action) end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ak_lsp_ruff", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.name ~= "ruff" then return end

    -- Disable hover in favor of Pyright
    vim.keymap.set("n", "<leader>co", code_action, { desc = desc, silent = true, buffer = args.buf })
    client.server_capabilities.hoverProvider = false
  end,
})

return {}
