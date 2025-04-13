-- https://github.com/latex-lsp/texlab
-- Arch linux: sudo pacman -S texlab
-- The texlab config in nvim-lspconfig is extensive...

local desc = "Vimtex Docs"
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("ak_lsp_texlab", {}),
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client.name ~= "texlab" then return end

    vim.keymap.set("n", "<Leader>K", "<plug>(vimtex-doc-package)", { desc = desc, silent = true, buffer = args.buf })
  end,
})
return {}
