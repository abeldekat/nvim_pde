--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local snip_engine = require("ak.util").snippets
local mini_snippets_standalone = require("ak.util").mini_snippets_standalone
local cmp = require("cmp")

-- Formatting:
local formatting = {
  format = function(_, item)
    local icon = MiniIcons and MiniIcons.get("lsp", item.kind)
    icon = icon and (" " .. icon .. " ") or icon
    if icon then item.kind = string.format("%s %s", icon, item.kind) end
    return item
  end,
}

-- Mappings
local mapping_override = { -- Does not map "tab"...
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(), -- invoke cmp manually
  -- Cmp assigns: ctrl-y and ctrl-e.
  ["<C-j>"] = cmp.mapping.confirm({ select = true }), -- like c-y, easier to type
}
if snip_engine == "none" then
  local next = function()
    if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
  end
  local prev = function()
    if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
  end

  mapping_override["<c-l>"] = cmp.mapping(next, { "i", "s" })
  mapping_override["<c-h>"] = cmp.mapping(prev, { "i", "s" })
end
local mapping = cmp.mapping.preset.insert(mapping_override)

-- Sources:
local sources = {
  { name = "nvim_lsp" },
  { name = "buffer" },
  { name = "path" },
}
if snip_engine == "mini" and not mini_snippets_standalone then table.insert(sources, 2, { name = "mini_snippets" }) end
sources = cmp.config.sources(sources)

-- Snippet expansion:
local snippet = { -- configure mini.snippets by default
  expand = function(args)
    ---@diagnostic disable-next-line: undefined-global
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
    insert({ body = args.body }) -- insert at cursor
  end,
}
if snip_engine == "none" then
  snippet["expand"] = nil -- cmp defaults to native snippets
end

-- Window
local window = {
  -- Default winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
  completion = cmp.config.window.bordered({
    -- Default winhighlight: "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None"
    winhighlight = "Normal:Normal,FloatBorder:None,CursorLine:PmenuSel,Search:None",
  }),
  -- Default winhighlight = 'FloatBorder:NormalFloat',
  documentation = cmp.config.window.bordered({
    -- Default winhighlight: "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None"
    winhighlight = "Normal:Normal,FloatBorder:None,CursorLine:PmenuSel,Search:None",
  }),
}

-- ---@type cmp.ConfigSchema
local opts = {
  formatting = formatting,
  mapping = mapping,
  snippet = snippet,
  sources = sources,
  window = window,
  -- instead of noselect, use noinsert
  completion = { completeopt = "menu,menuone,noinsert" }, -- in general you don't need to change this
  experimental = { ghost_text = { hl_group = "CmpGhostText" } },
  -- performance = { max_view_entries = 15 }, --- there is also sources.max_item_count
  -- view = { entries = { follow_cursor = true, }, }, --docs_auto_open
}

cmp.setup(opts)
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
