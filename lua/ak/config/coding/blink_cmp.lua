--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local Util = require("ak.util")

local sources = { default = { "lsp", "path", "buffer" }, cmdline = {} } -- disable cmdline

local snippets = {} -- blink defaults to it's own builtin with friendly snippets
if Util.snippets == "mini" then
  if Util.mini_snippets_standalone then -- don't add the snippets source
    snippets = {
      expand = function(snippet)
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = snippet })
      end,
      active = function(_) return MiniSnippets.session.get(false) ~= nil end,
      jump = function(direction) MiniSnippets.session.jump(direction == -1 and "prev" or "next") end,
    }
  else
    snippets = { preset = "mini_snippets" }
    table.insert(sources.default, 2, "snippets")
  end
elseif Util.snippets == "none" then
  table.insert(sources.default, 2, "snippets")
end

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
  ["<C-j>"] = { "select_and_accept" }, -- default c-y
  -- c-e is hide
  -- using builtin snippets: blink defines tab and shift-tab
  -- using mini.snippets: keymappings defined in mini.snippets
}

local opts = {
  appearance = appearance,
  completion = completion,
  keymap = keymap,
  signature = signature,
  snippets = snippets,
  sources = sources,
}

-- HACK: See blink cmp completion init, line 20
-- Fix outdated completion items:
local sources_lib = require("blink.cmp.sources.lib")
local orig_request_completions = sources_lib.request_completions
sources_lib.request_completions = vim.schedule_wrap(orig_request_completions)

local blink = require("blink.cmp")
blink.setup(opts)
