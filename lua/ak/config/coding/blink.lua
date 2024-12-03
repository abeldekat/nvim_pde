--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

-- TODO:

-- rust:  remove as_ref().unwrap() from fragment below:
-- self.sender.as_ref().unwrap().send(job).unwrap();
-- blink overrides send when typing as_ref before send

-- auto-brackets and signature_help are experimental
local opts = {
  keymap = {
    preset = "default", -- lazyvim uses enter
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

  -- experimental signature help support
  -- trigger = {
  --   -- completion = {}, -- defaults
  --   signature_help = {
  --     enabled = false, -- default false
  --   },
  -- },

  -- fuzzy = {}, -- defaults

  sources = {
    -- adding any nvim-cmp sources here will enable them
    -- with blink.compat
    compat = {},
    completion = {
      -- remember to enable your providers here
      enabled_providers = { "lsp", "path", "snippets", "buffer" },
    },
  },
  windows = {
    autocomplete = {
      -- draw = "reversed",
      winblend = vim.o.pumblend,
    },
    documentation = {
      auto_show = true, -- default false
    },
    -- signature_help = {},  -- defaults
    ghost_text = {
      enabled = true, -- default false
    },
  },

  highlight = {
    use_nvim_cmp_as_default = false,
  },

  -- nerd_font_variant = "mono", -- default mono

  -- blocked_filetypes = {}, -- defaults

  kind_icons = { -- TODO: override with mini.icons
    Text = "󰉿",
    Method = "󰊕",
    Function = "󰊕",
    Constructor = "󰒓",

    Field = "󰜢",
    Variable = "󰆦",
    Property = "󰖷",

    Class = "󱡠",
    Interface = "󱡠",
    Struct = "󱡠",
    Module = "󰅩",

    Unit = "󰪚",
    Value = "󰦨",
    Enum = "󰦨",
    EnumMember = "󰦨",

    Keyword = "󰻾",
    Constant = "󰏿",

    Snippet = "󱄽",
    Color = "󰏘",
    File = "󰈔",
    Reference = "󰬲",
    Folder = "󰉋",
    Event = "󱐋",
    Operator = "󰪚",
    TypeParameter = "󰬛",
  },
}
require("blink.cmp").setup(opts)
