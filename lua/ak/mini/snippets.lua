---@diagnostic disable: undefined-global
local mini_snippets, config_path = require('mini.snippets'), vim.fn.stdpath('config')
local stop_session_after_jumping_to_final_tabstop = false
local stop_all_sessions_on_normal_mode_exit = false

local latex_patterns = { 'latex/**/*.json', '**/latex.json' }
local lang_patterns = {
  tex = latex_patterns,
  plaintex = latex_patterns,
  -- Recognize special injected language of markdown tree-sitter parser
  markdown_inline = { 'markdown.json' },
}

-- From nvim echasnovski
local load_if_minitest_buf = function(context)
  local buf_name = vim.api.nvim_buf_get_name(context.buf_id)
  local is_test_buf = vim.fn.fnamemodify(buf_name, ':t'):find('^test_.+%.lua$') ~= nil
  if not is_test_buf then return {} end
  return MiniSnippets.read_file(config_path .. '/snippets/mini-test.json')
end

mini_snippets.setup({
  mappings = { jump_next = '', jump_prev = '' }, -- see ak.mini.keymap
  snippets = {
    mini_snippets.gen_loader.from_file(config_path .. '/snippets/global.json'),
    mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
    load_if_minitest_buf,
  },
})

if stop_session_after_jumping_to_final_tabstop then
  local fin_stop = function(args)
    if args.data.tabstop_to == '0' then MiniSnippets.session.stop() end
  end
  Config.new_autocmd('User', 'MiniSnippetsSessionJump', fin_stop)
end

if stop_all_sessions_on_normal_mode_exit then
  local make_stop = function()
    local au_opts = { pattern = '*:n', once = true }
    au_opts.callback = function()
      --stylua: ignore
      while MiniSnippets.session.get() do MiniSnippets.session.stop() end
    end
    vim.api.nvim_create_autocmd('ModeChanged', au_opts)
  end
  Config.new_autocmd('User', 'MiniSnippetsSessionStart', make_stop)
end
-- MiniSnippets.start_lsp_server()
