--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

local function snip_native()
  require("snippets").setup({ friendly_snippets = true, global_snippets = { "all", "global" } })
  return {
    source = { name = "snippets" },
    expand = nil, -- { expand = function(args) vim.snippet.expand(args.body) end },
    forward = function()
      if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
    end,
    backward = function()
      if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
    end,
  }
end

local function snip_luasnip()
  -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
  --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  local luasnip = require("luasnip")
  require("luasnip.loaders.from_vscode").lazy_load()
  luasnip.config.setup({
    history = true,
    delete_check_events = "TextChanged",
  })

  return {
    source = { name = "luasnip" },
    expand = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
    forward = function()
      if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
    end,
    backward = function()
      if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
    end,
  }
end

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

local cmp = require("cmp")
local snippets = false and snip_native() or snip_luasnip()

local formatting_style = {
  format = function(_, item)
    local icon = MiniIcons and MiniIcons.get("lsp", item.kind)
    icon = icon and (" " .. icon .. " ") or icon
    if icon then item.kind = string.format("%s %s", icon, item.kind) end
    return item
  end,
}

-- ---@type cmp.ConfigSchema
local opts = {
  completion = { completeopt = "menu,menuone,noinsert" },
  experimental = { ghost_text = { hl_group = "CmpGhostText" } },
  formatting = formatting_style,
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- invoke cmp manually

    -- Cmp assigns: ctrl-y and ctrl-e
    -- Override C-j(newline) because C-y is harder to type:
    ["<C-j>"] = cmp.mapping.confirm({ select = true }),

    -- TODO: problem on forward when text is "l"?
    ["<C-l>"] = cmp.mapping(snippets.forward, { "i", "s" }),
    ["<C-h>"] = cmp.mapping(snippets.backward, { "i", "s" }),
  }),
  snippet = snippets.expand,
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    snippets.source,
    { name = "buffer" },
    { name = "path" },
  }),
  -- view = { entries = { follow_cursor = true, }, }, --docs_auto_open
  window = {
    -- Default winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None',
    completion = cmp.config.window.bordered({
      -- Default winhighlight: "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None"
      winhighlight = "Normal:Normal,FloatBorder:None,CursorLine:PmenuSel,Search:None",
      -- scrollbar = false,
    }),
    -- Default winhighlight = 'FloatBorder:NormalFloat',
    documentation = cmp.config.window.bordered({
      -- Default winhighlight: "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None"
      winhighlight = "Normal:Normal,FloatBorder:None,CursorLine:PmenuSel,Search:None",
      -- scrollbar = false,
    }),
  },
  view = { entries = { follow_cursor = true } },
  -- TODO: scroll max entries in window?
}
cmp.setup(opts)
