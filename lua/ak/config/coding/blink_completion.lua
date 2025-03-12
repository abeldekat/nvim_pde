--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local blink = require("blink.cmp")

local snippets_standalone = require("ak.util").snippets_standalone
local snip_engine = "mini" -- nil

local completion = {
  menu = { draw = { treesitter = { "lsp" } } },
  documentation = { auto_show = true, auto_show_delay_ms = 200 },
  ghost_text = { enabled = true },
}

local keymap = { preset = "default" }
local signature = { enabled = true } -- false by default

local sources = { default = { "lsp", "path", "buffer" } }
local mode_cmdline = { enabled = false }
local mode_term = { enabled = false }

local snippets = {} -- blink defaults to it's own builtin
if snip_engine == "mini" and snippets_standalone then
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
  table.insert(sources.default, 3, "snippets")
  if snip_engine == "mini" then snippets = { preset = "mini_snippets" } end
end

local opts = {
  completion = completion,
  keymap = keymap,
  signature = signature,
  snippets = snippets,
  sources = sources,
  cmdline = mode_cmdline,
  term = mode_term,
}
blink.setup(opts)
