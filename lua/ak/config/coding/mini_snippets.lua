-- NOTE: supports choices in tabstop as well as variable transformations

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
local no_supertab = true

local function add_expand_mapping()
  -- The default:
  -- vim.keymap.set("i", "<c-k>", "<Cmd>lua MiniSnippets.expand()<CR>", { desc = "Expand snippet" })
  -- Create customized expand mappings:
  local expand = function() MiniSnippets.expand() end
  vim.keymap.set("i", "<c-k>", expand, { desc = "Expand snippet" })
  -- Add extra expand all mapping:
  local expand_all = function() MiniSnippets.expand({ match = false }) end
  vim.keymap.set("i", "<C-g><C-k>", expand_all, { desc = "Expand all snippet" })
end

local function add_expand_supertab_mapping(opts) -- testing supertab
  local expand_or_jump = function()
    local can_expand = #MiniSnippets.expand({ insert = false }) > 0
    if can_expand then
      vim.schedule(MiniSnippets.expand)
      return ""
    end

    local is_active = MiniSnippets.session.get(false) ~= nil
    if is_active then
      MiniSnippets.session.jump("next")
      return ""
    end

    return "\t"
  end
  local jump_prev = function() MiniSnippets.session.jump("prev") end
  local match_strict = function(candidate_snippets)
    -- Do not match with whitespace to cursor's left
    return MiniSnippets.default_match(candidate_snippets, { pattern_fuzzy = "%S+" })
  end

  opts.mappings = { expand = "", jump_next = "", jump_prev = "" } -- override mappings
  opts.expand["match"] = match_strict

  -- Note: These mappings are permanent, as opposed to the default jump mappings
  vim.keymap.set("i", "<Tab>", expand_or_jump, { expr = true, desc = "MiniSnippets supertab" })
  vim.keymap.set("i", "<S-Tab>", jump_prev, { desc = "MiniSnippets" })

  return opts
end

-- Fixes:
-- select - vim.ui.select: ghost_text appearing
-- select - vim.ui.select: cmp popups cover picker
local function select_override_standalone(snippets, insert)
  if Util.completion == "nvim-cmp" then
    local cmp = require("cmp")
    if cmp.visible() then cmp.close() end
    MiniSnippets.default_select(snippets, insert)
  elseif Util.completion == "blink" then
    require("blink.cmp").cancel() -- cancel uses vim.schedule
    vim.schedule(function() MiniSnippets.default_select(snippets, insert) end)
  else
    MiniSnippets.default_select(snippets, insert)
  end
end

-- TODO:
local function insert_override_standalone(snippet)
  if Util.completion == "nvim-cmp" then
    MiniSnippets.default_insert(snippet)
    -- require("cmp.config").set_onetime({ -- testing...
    --   sources = {},
    -- })
  else
    MiniSnippets.default_insert(snippet)
  end
end

local mini_snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")

local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }
local snippets = {
  -- completion on direct expand, no completion via cmp-mini-snippets:
  { prefix = "aaa1", body = "T1=fu$1", desc = "fu before $1" },
  -- completion on direct expand, no completion via cmp-mini-snippets:
  { prefix = "aaa2", body = "T1=fu$1 $0", desc = "fu before $1 and space after" },
  -- no completion on direct expand, completion via cmp-mini-snippets
  { prefix = "aaa9", body = "T1=${1:9} T2=${2:<$1>}", desc = "test test" },
  --
  mini_snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
  mini_snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
}
-- I already use <c-j> to confirm completion.
--
-- Digraph: CTRL-K {char1} [char2] Enter digraph (see |digraphs|).
-- I almost never enter a digraph.
-- The key used to be overriden in ak.config.lang.lspconfig for signature help in insert mode.
-- I also seldomly invoke signature help in insert mode.
-- Solution: use <c-k> for snippets and <c-s> for signature help in insert mode.
-- To enter a digraph, start nvim without plugins.
local mappings = { expand = "" }

local expand = Util.mini_snippets_standalone
    and {
      select = select_override_standalone,
      insert = insert_override_standalone,
    }
  or nil

local opts = {
  snippets = snippets,
  mappings = mappings,
  expand = expand,
}

if no_supertab then
  add_expand_mapping() -- map expand from <c-j> to <c-k> in this module
else
  opts = add_expand_supertab_mapping(opts) -- testing...
end
mini_snippets.setup(opts)
