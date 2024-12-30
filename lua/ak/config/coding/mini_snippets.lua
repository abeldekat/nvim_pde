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

local test_supertab = false
local Util = require("ak.util")
local snippets, config_path = require("mini.snippets"), vim.fn.stdpath("config")
local lang_patterns = { tex = { "latex.json" }, plaintex = { "latex.json" } }

local function add_expand_keys()
  -- create customized expand mappings:

  -- The default:
  -- vim.keymap.set("i", "<c-k>", "<Cmd>lua MiniSnippets.expand()<CR>", { desc = "Expand snippet" })
  local expand = function() MiniSnippets.expand() end
  vim.keymap.set("i", "<c-k>", expand, { desc = "Expand snippet" })

  -- Add extra expand all mapping:
  local expand_all = function() MiniSnippets.expand({ match = false }) end
  vim.keymap.set("i", "<C-g><C-k>", expand_all, { desc = "Expand all snippet" })
end

-- Testing: Supertab as described in the help
local function add_supertab_keys(opts)
  local expand_or_jump = function()
    local can_expand = #MiniSnippets.expand({ insert = false }) > 0
    if can_expand then
      vim.schedule(MiniSnippets.expand)
      return ""
    end

    ---@diagnostic disable-next-line: missing-parameter
    local is_active = MiniSnippets.session.get() ~= nil
    if is_active then
      MiniSnippets.session.jump("next")
      return ""
    end

    return "\t"
  end
  local jump_prev = function() MiniSnippets.session.jump("prev") end
  local match_strict = function(candidate_snippets)
    -- Do not match with whitespace to cursor's left
    return snippets.default_match(candidate_snippets, { pattern_fuzzy = "%S+" })
  end

  opts.mappings = { expand = "", jump_next = "", jump_prev = "" } -- override mappings
  opts.expand["match"] = match_strict

  -- Note: These mappings are permanent, as opposed to the default jump mappings
  vim.keymap.set("i", "<Tab>", expand_or_jump, { expr = true, desc = "MiniSnippets supertab" })
  vim.keymap.set("i", "<S-Tab>", jump_prev, { desc = "MiniSnippets" })

  return opts
end

local function select_override(the_snippets, insert)
  if Util.completion == "nvim-cmp" then
    local cmp = require("cmp")
    if cmp.visible() then cmp.close() end
    MiniSnippets.default_select(the_snippets, insert)
  elseif Util.completion == "blink" then
    -- Cancel uses vim.schedule
    require("blink.cmp").cancel() -- overriden in blink config!
    -- Schedule default_select, otherwise blink's virtual text is not removed
    -- when mini.snippets opens vim.ui.select
    vim.schedule(function() MiniSnippets.default_select(the_snippets, insert) end)
  else
    MiniSnippets.default_select(the_snippets, insert)
  end
end

-- I already use <c-j> to confirm completion.
--
-- Digraph: CTRL-K {char1} [char2] Enter digraph (see |digraphs|).
-- I almost never enter a digraph.
-- The key used to be overriden in ak.config.lang.lspconfig for signature help in insert mode.
-- I also seldomly invoke signature help in insert mode.
-- Solution: use <c-k> for snippets and <c-s> for signature help in insert mode.
-- To enter a digraph, start nvim without plugins.
local mappings = { expand = "" }

local opts = {
  snippets = {
    snippets.gen_loader.from_file(config_path .. "/snippets/global.json"),
    snippets.gen_loader.from_lang({ lang_patterns = lang_patterns }),
  },
  mappings = mappings, -- map expand from <c-j> to <c-k> in this module
  expand = { select = select_override },
}

if not test_supertab then
  add_expand_keys()
else
  opts = add_supertab_keys(opts) -- override mappings.expand...
end
snippets.setup(opts)
