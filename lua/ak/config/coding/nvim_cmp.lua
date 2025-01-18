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
local snippet = {
  expand = function(args)
    ---@diagnostic disable-next-line: undefined-global
    local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
    insert({ body = args.body }) -- insert at cursor
  end,
}
if snip_engine == "none" then
  snippet["expand"] = nil -- cmp defaults to native snippets
end

-- Snippet fix outdated completion items:
-- https://github.com/hrsh7th/nvim-cmp/pull/2126
if snip_engine == "mini" then
  local group = vim.api.nvim_create_augroup("mini_snippets_nvim_cmp", { clear = true })

  -- NOTE: Firstly, make sure that nvim-cmp never provides completion items directly after snippet insert
  -- See https://github.com/abeldekat/cmp-mini-snippets/issues/6
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniSnippetsSessionStart",
    callback = function() require("cmp.config").set_onetime({ sources = {} }) end,
  })

  -- HACK: Secondly, it's now possible to prevent outdated completion items
  -- See https://github.com/hrsh7th/nvim-cmp/issues/2119
  local function make_complete_override(complete_fn)
    return function(self, params, callback)
      local override_fn = complete_fn
      if MiniSnippets.session.get(false) ~= nil then override_fn = vim.schedule_wrap(override_fn) end
      override_fn(self, params, callback)
    end
  end
  local function find_cmp_nvim_lsp(id)
    for _, source in ipairs(require("cmp").get_registered_sources()) do
      if source.id == id and source.name == "nvim_lsp" then return source.source end
    end
  end
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "CmpRegisterSource",
    callback = function(ev)
      local cmp_nvim_lsp = find_cmp_nvim_lsp(ev.data.source_id)
      if cmp_nvim_lsp then
        local org_complete = cmp_nvim_lsp.complete
        cmp_nvim_lsp.complete = make_complete_override(org_complete)
      end
    end,
  })
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
  -- instead of noselect, use noinsert:
  completion = { completeopt = "menu,menuone,noinsert" }, -- in general you don't need to change this
  experimental = { ghost_text = { hl_group = "CmpGhostText" } },
  -- performance = { max_view_entries = 15 }, --- there is also sources.max_item_count
  -- view = { entries = { follow_cursor = true, }, }, --docs_auto_open
}

cmp.setup(opts)
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
