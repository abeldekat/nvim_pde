local Util = require("ak.util")

local mini_snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }
local stop_session_after_jumping_to_final_tabstop = false
local stop_all_sessions_on_normal_mode_exit = false

mini_snippets.setup({
  expand = {
    select = function(snippets, insert)
      if Util.completion == "blink" then -- blink popup covers snippet picker
        require("blink.cmp").cancel() -- cancel uses vim.schedule
        vim.schedule(function() MiniSnippets.default_select(snippets, insert) end)
        return
      end
      MiniSnippets.default_select(snippets, insert)
    end,
  },
  mappings = { jump_next = "", jump_prev = "" }, -- defined in map_multistep
  snippets = {
    mini_snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
    mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },
})

local no_pmenu = { -- make sure pmenu is closed after snippets and before jump
  condition = function() return vim.fn.pumvisible() == 1 end,
  action = function()
    vim.schedule(function() -- see mini.snippets, H.hide_completion
      if vim.fn.mode() == "i" then vim.cmd('silent noautocmd call complete(col("."), [])') end
    end)
    return false
  end,
}
local steps_ctrl_l = { "minisnippets_next", no_pmenu, "jump_after_tsnode", "jump_after_close" }
MiniKeymap.map_multistep("i", "<C-l>", steps_ctrl_l)
local steps_ctrl_h = { "minisnippets_prev", no_pmenu, "jump_before_tsnode", "jump_before_open" }
MiniKeymap.map_multistep("i", "<C-h>", steps_ctrl_h)

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })

if stop_session_after_jumping_to_final_tabstop then
  local fin_stop = function(args)
    if args.data.tabstop_to == "0" then MiniSnippets.session.stop() end
  end
  local au_opts = { pattern = "MiniSnippetsSessionJump", callback = fin_stop }
  vim.api.nvim_create_autocmd("User", au_opts)
end

if stop_all_sessions_on_normal_mode_exit then
  local make_stop = function()
    local au_opts = { pattern = "*:n", once = true }
    au_opts.callback = function()
      while MiniSnippets.session.get() do
        MiniSnippets.session.stop()
      end
    end
    vim.api.nvim_create_autocmd("ModeChanged", au_opts)
  end
  local opts = { pattern = "MiniSnippetsSessionStart", callback = make_stop }
  vim.api.nvim_create_autocmd("User", opts)
end
