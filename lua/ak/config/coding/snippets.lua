-- The help:
--
-- General advice:
-- - Put files in "snippets" subdirectory of any path in 'runtimepath' (like
--   "$XDG_CONFIG_HOME/nvim/snippets/global.json").
--   This is compatible with |MiniSnippets.gen_loader.from_runtime()| and
--   example from |MiniSnippets-examples|.
-- - Prefer `*.json` files with dict-like content if you want more cross platfrom
-- setup. Otherwise use `*.lua` files with array-like content.

local Util = require("ak.util")

-- Fixes:
-- select - vim.ui.select: ghost_text appearing
-- select - vim.ui.select: cmp popups cover picker
local function expand_select_override(snippets, insert)
  if Util.cmp == "cmp" then
    local cmp = require("cmp")
    if cmp.visible() then cmp.close() end
    MiniSnippets.default_select(snippets, insert)
  elseif Util.cmp == "blink" then
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

local expand = {}
if Util.snippets_standalone then expand["select"] = expand_select_override end

mini_snippets.setup({
  snippets = snippets,
  expand = expand,
})

local rhs = function() MiniSnippets.expand({ match = false }) end
vim.keymap.set("i", "<C-g><C-j>", rhs, { desc = "Expand all" })
