--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")
local blink = require("blink.cmp")

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

-- blink does not have any c-j, c-l or c-h mappings, c-e is hide
local keymap = {
  preset = "default",
  ["<C-j>"] = { "select_and_accept" }, -- like default c-y
  ["<c-k>"] = {}, -- in use by mini.snippets { 'show_signature', 'hide_signature', 'fallback' }
}
local signature = { enabled = true } -- false by default
if signature.enabled then keymap["<c-s>"] = { "show_signature", "hide_signature", "fallback" } end

local sources = {
  default = { "lsp", "path", "buffer" },
  cmdline = {
    -- disable cmdline
  },
  term = {
    -- disable future term
  },
}

local snippets = {} -- blink defaults to it's own builtin
if Util.snippets == "mini" and Util.snippets_standalone then
  snippets = { -- don't add sources.snippets, copy expand active and jump from config-snippets
    expand = function(snippet)
      local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      insert({ body = snippet })
      blink.resubscribe()
    end,
    active = function(_) return MiniSnippets.session.get(false) ~= nil end,
    jump = function(direction) MiniSnippets.session.jump(direction == -1 and "prev" or "next") end,
  }
else
  table.insert(sources.default, 2, "snippets")
  if Util.snippets == "mini" then snippets = { preset = "mini_snippets" } end
end

local opts = {
  completion = completion,
  keymap = keymap,
  signature = signature,
  snippets = snippets,
  sources = sources,
}
blink.setup(opts)
