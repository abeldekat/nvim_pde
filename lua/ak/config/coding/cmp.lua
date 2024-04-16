--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

local cmp = require("cmp")
local defaults = require("cmp.config.default")()
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({
  history = true,
  delete_check_events = "TextChanged",
})

-- ---@type cmp.ConfigSchema
local opts = {
  completion = { completeopt = "menu,menuone,noinsert" },
  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- invoke cmp manually

    -- kickstart:
    ["C-y"] = cmp.mapping.confirm({ select = true }), -- kickstart: <C-y>
    -- lazyvim:
    -- Set `select` to `false` to only confirm explicitly selected items.
    -- ["<C-e>"] = cmp.mapping.abort(), -- kickstart: not present
    -- ["<CR>"] = cmp.mapping.confirm({ select = true }), -- kickstart: <C-y>
    -- ["<S-CR>"] = cmp.mapping.confirm({ -- kickstart: not present
    --   behavior = cmp.ConfirmBehavior.Replace,
    --   select = true,
    -- }),
    -- ["<C-CR>"] = function(fallback) -- kickstart: not present
    --   cmp.abort()
    --   fallback()
    -- end,

    -- Previously, lazyvim:
    -- vim.keymap.set("i", "<tab>", function()
    --   return require("luasnip").jumpable(1) and "<plug>luasnip-jump-next" or "<tab>"
    -- end, { expr = true, silent = true })
    -- vim.keymap.set("s", "<tab>", function()
    --   return require("luasnip").jump(1)
    -- end, {})
    -- vim.keymap.set({ "i", "s" }, "<s-tab>", function()
    --   return require("luasnip").jump(-1)
    -- end, {})

    -- Kickstart:
    -- Think of <c-l> as moving to the right of your snippet expansion.
    --  So if you have a snippet that's like:
    --  function $name($args)
    --    $body
    --  end
    --
    -- <c-l> will move you to the right of each of the expansion locations.
    -- <c-h> is similar, except moving you backwards.
    ["<C-l>"] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
    end, { "i", "s" }),
    ["<C-h>"] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
    end, { "i", "s" }),

    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
  }, {
    { name = "path" },
  }),
  ---@diagnostic disable-next-line: missing-fields
  formatting = {
    format = function(_, item)
      local icons = require("ak.consts").icons.kinds
      if icons[item.kind] then item.kind = icons[item.kind] .. item.kind end
      return item
    end,
  },
  experimental = {
    ghost_text = {
      hl_group = "CmpGhostText",
    },
  },
  sorting = defaults.sorting,
  view = {
    entries = {
      follow_cursor = true,
    },
  },
}
for _, source in ipairs(opts.sources) do
  source.group_index = source.group_index or 1
end
cmp.setup(opts)
