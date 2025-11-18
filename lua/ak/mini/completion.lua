-- TODO: why is omni cleaner
-- TODO: Completefunc to use ctrl-o to temporarily escape to normal mode. See mini discussions #1736

-- Customize post-processing of LSP responses for a better user experience.
-- Don't show 'Text' suggestions (usually noisy) and show snippets last.
local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
local process_items = function(items, base) return MiniCompletion.default_process_items(items, base, process_items_opts) end
require("mini.completion").setup({
  lsp_completion = {
    -- Without this config autocompletion is set up through `:h 'completefunc'`.
    -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
    -- (sets up only when needed) and makes it possible to use `<C-u>`.
    source_func = "omnifunc",
    auto_setup = false,
    process_items = process_items,
  },
})

-- Set 'omnifunc' for LSP completion only when needed.
local on_attach = function(ev) vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp" end
_G.Config.new_autocmd("LspAttach", nil, on_attach, "Set 'omnifunc'")

-- Advertise to servers that Neovim now supports certain set of completion and
-- signature features through 'mini.completion'.
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
