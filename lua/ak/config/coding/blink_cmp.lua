--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

-- Blink completion:
-- crust of rust declarative macros:
-- let mut y = Some(42);
-- let x: Vec<u32> = avec![42; 2];
-- > Now, change 42 in avec to y and type .take: No completion in blink 0.8.0, does work in 0.7.6
-- Reported bug https://github.com/Saghen/blink.cmp/issues/719

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
