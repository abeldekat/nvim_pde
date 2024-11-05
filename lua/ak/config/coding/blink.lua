--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

-- auto-brackets and signature_help are experimental
local opts = {
  keymap = {
    preset = "default",
    -- c-e is hide
    ["<C-j>"] = { "select_and_accept" }, -- default c-y
    ["<C-l>"] = { "snippet_forward", "fallback" }, -- default tab
    ["<C-h>"] = { "snippet_backward", "fallback" }, -- default s-tab
  },
  -- experimental auto-brackets support
  accept = {
    auto_brackets = {
      enabled = true, -- default false
    },
  },
  -- trigger = {
  --   -- completion = {}, -- defaults
  --   signature_help = {
  --     enabled = false, -- default false
  --   },
  -- },
  -- fuzzy = {}, -- defaults
  -- sources = {}, -- defaults
  windows = {
    -- autocomplete = {}, -- defaults
    documentation = {
      auto_show = true, -- default false
    },
    -- signature_help = {},  -- defaults
    ghost_text = {
      enabled = true, -- default false
    },
  },

  highlight = {
    use_nvim_cmp_as_default = false, -- default false
  },
  -- nerd_font_variant = "mono", -- default mono
  -- blocked_filetypes = {}, -- defaults
  -- kind_icons = {}, -- defaults
}
require("blink.cmp").setup(opts)
