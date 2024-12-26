--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local snip_engine = require("ak.util").snippets
local cmp = require("cmp")

-- Formatting:
local formatting_style = {
  format = function(_, item)
    local icon = MiniIcons and MiniIcons.get("lsp", item.kind)
    icon = icon and (" " .. icon .. " ") or icon
    if icon then item.kind = string.format("%s %s", icon, item.kind) end
    return item
  end,
}

-- Mappings
local mapping_override = {
  ["<C-b>"] = cmp.mapping.scroll_docs(-4),
  ["<C-f>"] = cmp.mapping.scroll_docs(4),
  ["<C-Space>"] = cmp.mapping.complete(), -- invoke cmp manually

  -- Cmp assigns: ctrl-y and ctrl-e
  -- Override C-j(newline) because C-y is harder to type:
  ["<C-j>"] = cmp.mapping.confirm({ select = true }),
}
if snip_engine == "none" then -- mini.snippets defines own mapping...
  mapping_override["<C-l>"] = cmp.mapping(function()
    if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
  end, { "i", "s" })
  mapping_override["<C-h>"] = cmp.mapping(function()
    if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
  end, { "i", "s" })
elseif snip_engine == "luasnip" then
  local luasnip = require("luasnip")

  -- TODO: problem on forward when text is "l"?
  mapping_override["<C-l>"] = cmp.mapping(function()
    if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
  end, { "i", "s" })
  mapping_override["<C-h>"] = cmp.mapping(function()
    if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
  end, { "i", "s" })
end
local mapping = cmp.mapping.preset.insert(mapping_override)

-- Sources: NOTE: only luasnip can be added as extra "source"
local sources = cmp.config.sources({
  { name = "nvim_lsp" },
  snip_engine == "luasnip" and { name = "luasnip" } or nil,
  { name = "buffer" },
  { name = "path" },
})

-- Snippet expansion: Defaults to native: { expand = function(args) vim.snippet.expand(args.body) end }
local snippet = {}
if snip_engine == "luasnip" then
  snippet["expand"] = function(args) require("luasnip").lsp_expand(args.body) end
elseif snip_engine == "mini" then
  snippet["expand"] = function(args)
    ---@diagnostic disable-next-line: undefined-global
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
    -- Insert at cursor
    insert({ body = args.body })
  end
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
  formatting = formatting_style,
  mapping = mapping,
  snippet = snippet,
  sources = sources,
  completion = { completeopt = "menu,menuone,noinsert" },
  experimental = { ghost_text = { hl_group = "CmpGhostText" } },
  window = window,

  -- TESTING:
  -- performance = { max_view_entries = 15 }, --- there is also sources.max_item_count
  -- view = { entries = { follow_cursor = true, }, }, --docs_auto_open
}

cmp.setup(opts)
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
