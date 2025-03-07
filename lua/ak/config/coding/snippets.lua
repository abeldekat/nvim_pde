-- The help:
--
-- General advice:
-- - Put files in "snippets" subdirectory of any path in 'runtimepath' (like
--   "$XDG_CONFIG_HOME/nvim/snippets/global.json").
--   This is compatible with |MiniSnippets.gen_loader.from_runtime()| and
--   example from |MiniSnippets-examples|.
-- - Prefer `*.json` files with dict-like content if you want more cross platfrom
-- setup. Otherwise use `*.lua` files with array-like content.

-- local function add_expand_supertab_mapping(opts) -- testing supertab
--   local expand_or_jump = function()
--     local can_expand = #MiniSnippets.expand({ insert = false }) > 0
--     if can_expand then
--       vim.schedule(MiniSnippets.expand)
--       return ""
--     end
--
--     local is_active = MiniSnippets.session.get(false) ~= nil
--     if is_active then
--       MiniSnippets.session.jump("next")
--       return ""
--     end
--
--     return "\t"
--   end
--   local jump_prev = function() MiniSnippets.session.jump("prev") end
--   local match_strict = function(candidate_snippets)
--     -- Do not match with whitespace to cursor's left
--     return MiniSnippets.default_match(candidate_snippets, { pattern_fuzzy = "%S+" })
--   end
--
--   opts.mappings = { expand = "", jump_next = "", jump_prev = "" } -- override mappings
--   opts.expand["match"] = match_strict
--
--   -- Note: These mappings are permanent, as opposed to the default jump mappings
--   vim.keymap.set("i", "<Tab>", expand_or_jump, { expr = true, desc = "MiniSnippets supertab" })
--   vim.keymap.set("i", "<S-Tab>", jump_prev, { desc = "MiniSnippets" })
--
--   return opts
-- end

local Util = require("ak.util")
local expand_mapping = Util.cmp == "mini" and "<c-j>" or "<c-k>"

local function add_expand_mapping()
  local expand = function() MiniSnippets.expand() end
  vim.keymap.set("i", expand_mapping, expand, { desc = "Expand snippet" })

  local expand_all = function() MiniSnippets.expand({ match = false }) end
  vim.keymap.set("i", "<C-g>" .. expand_mapping, expand_all, { desc = "Expand all snippet" })
end

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

-- I already use <c-j> to confirm completion in cmp and blink.
--
-- Digraph: CTRL-K {char1} [char2] Enter digraph (see |digraphs|).
-- I almost never enter a digraph.
-- The key used to be overriden in ak.config.lang.lspconfig for signature help in insert mode.
-- I also seldomly invoke signature help in insert mode.
-- Solution: use <c-k> for snippets and <c-s> for signature help in insert mode.
-- To enter a digraph, start nvim without plugins.
local mappings = { expand = "" }

local expand = {}
if Util.snippets_standalone then expand["select"] = expand_select_override end

local opts = {
  snippets = snippets,
  mappings = mappings,
  expand = expand,
}

add_expand_mapping()
mini_snippets.setup(opts)
