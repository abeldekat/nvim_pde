-- TODO: Neovim v0.11 now defines tab for snippets in _defaults. Unmap?

local Util = require("ak.util")

-- Fixes:
-- select - vim.ui.select: ghost_text appearing
-- select - vim.ui.select: cmp popups cover picker
local function expand_select_override(snippets, insert)
  if Util.completion == "blink" then
    require("blink.cmp").cancel() -- cancel uses vim.schedule
    vim.schedule(function() MiniSnippets.default_select(snippets, insert) end)
  else
    MiniSnippets.default_select(snippets, insert)
  end
end

local mini_snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")

local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }
local snippets = {
  mini_snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
  mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
}

mini_snippets.setup({
  snippets = snippets,
  expand = { select = expand_select_override },
})

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })
