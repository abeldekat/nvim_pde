--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local blink = require("blink.cmp")

local completion = {
  menu = { draw = { treesitter = { "lsp" } } },
  documentation = { auto_show = true, auto_show_delay_ms = 200 },
}
local keymap = { preset = "default" }
local mode_cmdline = { enabled = false }
local mode_term = { enabled = false }
local signature = { enabled = true } -- false by default
local snippets = { -- don't add sources.snippets, copy expand active and jump from config-snippets
  expand = function(snippet)
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
    insert({ body = snippet })
    blink.resubscribe()
  end,
  active = function(_) return MiniSnippets.session.get(false) ~= nil end,
  jump = function(direction) MiniSnippets.session.jump(direction == -1 and "prev" or "next") end,
}
local sources = { default = { "lsp", "path", "buffer" } }

local opts = {
  cmdline = mode_cmdline,
  completion = completion,
  keymap = keymap,
  signature = signature,
  snippets = snippets,
  sources = sources,
  term = mode_term,
}
blink.setup(opts)
