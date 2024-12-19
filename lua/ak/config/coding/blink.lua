--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local opts = {
  keymap = {
    preset = "default", -- lazyvim uses enter
    -- c-e is hide
    ["<C-j>"] = { "select_and_accept" }, -- default c-y
    ["<C-l>"] = { "snippet_forward", "fallback" }, -- default tab
    ["<C-h>"] = { "snippet_backward", "fallback" }, -- default s-tab
  },

  completion = {
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
    ghost_text = {
      enabled = true,
    },
  },

  sources = { -- disable cmdline:
    cmdline = {},
  },

  signature = {
    enabled = true,
  },

  appearance = {
    use_nvim_cmp_as_default = false,
  },
}

require("blink.cmp").setup(opts)
