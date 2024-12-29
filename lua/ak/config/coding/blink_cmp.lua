--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

-- Blink completion:
-- crust of rust declarative macros:
-- let mut y = Some(42);
-- let x: Vec<u32> = avec![42; 2];
-- > Now, change 42 in avec to y and type .take: No completion in blink 0.8.0, does work in 0.7.6
-- Reported bug https://github.com/Saghen/blink.cmp/issues/719

local sources = { cmdline = {} } -- disable cmdline:
local signature = { enabled = true } -- false by default
local appearance = {} ---  use_nvim_cmp_as_default = false

local completion = {
  menu = {
    draw = {
      treesitter = { "lsp" },
    },
  },
  documentation = {
    -- Controls whether the documentation window will automatically show when selecting a completion item
    auto_show = true,
    -- -- Delay before showing the documentation window
    auto_show_delay_ms = 200,
  },
  ghost_text = { enabled = true },
}

-- blink does not have any c-j, c-l or c-h mappings
local keymap = {
  preset = "default", -- lazyvim uses enter
  -- c-e is hide
  ["<C-j>"] = { "select_and_accept" }, -- default c-y
  ["<C-l>"] = { "snippet_forward", "fallback" }, -- default tab
  ["<C-h>"] = { "snippet_backward", "fallback" }, -- default s-tab
}

local snippets = {} -- blink defaults to vim.snippet builtin
if Util.snippets == "mini" then
  snippets = {
    expand = function(snippet)
      ---@diagnostic disable-next-line: undefined-global
      local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      insert({ body = snippet }) -- Insert at cursor
    end,
    active = function(_)
      return false -- mini.snippets operates standalone, invoked by c-j
    end,
    jump = function()
      -- blink does not define mini.snippets default c-j, c-l or c-h mappings
      -- do nothing. Only use the mappings provided by mini.snippets
    end,
  }
end

local opts = {
  appearance = appearance,
  completion = completion,
  keymap = keymap,
  signature = signature,
  snippets = snippets,
  sources = sources,
}

local blink = require("blink.cmp")
blink.setup(opts)
