-- Disabled these features better provided by LSP or other more general plugins
vim.g["semshi#error_sign"] = false
vim.g["semshi#simplify_markup"] = false
vim.g["semshi#mark_selected_nodes"] = false
vim.g["semshi#update_delay_factor"] = 0.001

local function add_highlights()
  -- Only add style, inherit or link to the LSP's colors
  vim.cmd([[
            highlight! link semshiGlobal  @none
            highlight! link semshiImported @none
            highlight! link semshiParameter @lsp.type.parameter
            highlight! link semshiBuiltin @function.builtin
            highlight! link semshiAttribute @field
            highlight! link semshiSelf @lsp.type.selfKeyword
            highlight! link semshiUnresolved @none
            highlight! link semshiFree @none
            highlight! link semshiAttribute @none
            highlight! link semshiParameterUnused @none
            ]])
end
vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, { -- VimEnter
  group = vim.api.nvim_create_augroup("SemanticHighlight", {}),
  callback = add_highlights,
})
