local blink = require("blink.cmp")

local get_icon = function(ctx) -- TODO: fixed on "lsp"
  local icon, _, _ = MiniIcons.get("lsp", ctx.kind)
  return icon
end
local get_icon_hl = function(ctx)
  local _, hl, _ = MiniIcons.get("lsp", ctx.kind)
  return hl
end

local completion = {
  documentation = { auto_show = true, auto_show_delay_ms = 200 },
  -- Preselect false is less intrusive: no automatic docs, no automatic *visible* selection
  list = { selection = { preselect = false, auto_insert = true } },
  menu = {
    draw = {
      treesitter = { "lsp" },
      components = {
        kind_icon = {
          text = function(ctx) return get_icon(ctx) end,
          highlight = function(ctx) return get_icon_hl(ctx) end,
        },
        kind = { highlight = function(ctx) return get_icon_hl(ctx) end },
      },
    },
  },
}

local keymap = {
  preset = "default",
  ["<c-k>"] = { -- prefer typing c-k over c-y to accept "kompletion"
    function(cmp)
      if cmp.is_visible() then return cmp.select_and_accept() end
    end,
    "fallback", -- digraph
  },
  ["S-Tab"] = {}, -- using mini.snippets standalone
  ["Tab"] = {}, -- using mini.snippets standalone
}

local snippets_standalone = { -- copy expand/active from config-snippets, don't add sources.snippets
  expand = function(snippet)
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
    insert({ body = snippet })
    blink.resubscribe()
  end,
  active = function(_) return MiniSnippets.session.get(false) ~= nil end,
}

local sources = { default = { "lsp", "buffer" } } -- "path"

blink.setup({
  cmdline = { enabled = false },
  completion = completion,
  keymap = keymap,
  signature = { enabled = true },
  snippets = snippets_standalone,
  sources = sources,
  term = { enabled = false },
})
