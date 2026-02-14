local mini_snippets, config_path = require('mini.snippets'), vim.fn.stdpath('config')
local stop_session_after_jumping_to_final_tabstop = true
local stop_all_sessions_on_normal_mode_exit = true

local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
local lang_patterns = {
  tex = latex_patterns,
  plaintex = latex_patterns,
  -- Recognize special injected language of markdown tree-sitter parser
  markdown_inline = { 'markdown.json' },
}

mini_snippets.setup({
  mappings = { jump_next = '', jump_prev = '' }, -- defined in map_multistep
  snippets = {
    mini_snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
    mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },
})

local gr = vim.api.nvim_create_augroup('custom-snippets-config', {})
if stop_session_after_jumping_to_final_tabstop then
  local fin_stop = function(args)
    if args.data.tabstop_to == '0' then MiniSnippets.session.stop() end
  end
  local au_opts = { group = gr, pattern = 'MiniSnippetsSessionJump', callback = fin_stop }
  vim.api.nvim_create_autocmd('User', au_opts)
end

if stop_all_sessions_on_normal_mode_exit then
  local make_stop = function()
    local au_opts = { pattern = '*:n', once = true }
    au_opts.callback = function()
      -- stylua: ignore
      while MiniSnippets.session.get() do MiniSnippets.session.stop() end
    end
    vim.api.nvim_create_autocmd('ModeChanged', au_opts)
  end
  local opts = { group = gr, pattern = 'MiniSnippetsSessionStart', callback = make_stop }
  vim.api.nvim_create_autocmd('User', opts)
end

-- By default snippets available at cursor are not shown as candidates in
-- 'mini.completion' menu. This requires a dedicated in-process LSP server
-- that will provide them. To have that, uncomment next line (use `gcc`).
-- MiniSnippets.start_lsp_server()
