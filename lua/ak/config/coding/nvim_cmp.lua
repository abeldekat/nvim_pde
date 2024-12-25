--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

-- NOTE: mini.snippets: for now, not connected to cmp

local Util = require("ak.util")

local function snip_native_lsp_expansion() -- just lsp expansion, no plugin needed
  return {
    source = nil,
    expand = nil, -- { expand = function(args) vim.snippet.expand(args.body) end },
    forward = function()
      if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
    end,
    -- TODO: "callsnippet": ctrl-h does not work when at the end of snippet
    -- Fortunately, it does work when there are more than 2 place holders
    backward = function()
      -- if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
      vim.snippet.jump(-1)
    end,
  }
end

local function snip_luasnip()
  local luasnip = require("luasnip")
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
local snippets = Util.snippets == "luasnip" and snip_luasnip() or snip_native_lsp_expansion()

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
    -- ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }), -- = default
    -- ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }), -- = default
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

  -- TESTING:
  -- performance = { max_view_entries = 15 }, --- there is also sources.max_item_count

  snippet = snippets.expand,
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    snippets.source, -- can be nil
    { name = "buffer" },
    { name = "path" },
  }),
  -- view = { entries = { follow_cursor = true, }, }, --docs_auto_open
  window = {
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
  },
  -- view = { entries = { follow_cursor = true } },
}

cmp.setup(opts)
