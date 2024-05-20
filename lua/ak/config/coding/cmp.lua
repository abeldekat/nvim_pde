--          ╭─────────────────────────────────────────────────────────╮
--          │                   Also see: lsp                         │
--          ╰─────────────────────────────────────────────────────────╯

vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })

local cmp = require("cmp")
local defaults = require("cmp.config.default")()

local function snips_to_cmp(use_native)
  return use_native
      and {
        source = { name = "snippets" },
        expand = { expand = function(args) vim.snippet.expand(args.body) end },
        forward = function()
          if vim.snippet.active({ direction = 1 }) then vim.snippet.jump(1) end
        end,
        backward = function()
          if vim.snippet.active({ direction = -1 }) then vim.snippet.jump(-1) end
        end,
      }
    or {
      -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      source = { name = "luasnip" },
      expand = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
      forward = function()
        local luasnip = require("luasnip")
        if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
      end,
      snip_backward = function()
        local luasnip = require("luasnip")
        if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
      end,
    }
end

local use_native_snippets = true
local snippets = snips_to_cmp(use_native_snippets)
if use_native_snippets then
  require("snippets").setup({ friendly_snippets = true })
else
  require("luasnip.loaders.from_vscode").lazy_load()
  require("luasnip").config.setup({
    history = true,
    delete_check_events = "TextChanged",
  })
end

-- ---@type cmp.ConfigSchema
local opts = {
  completion = { completeopt = "menu,menuone,noinsert" },
  snippet = snippets.expand,
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- invoke cmp manually

    ["C-y"] = cmp.mapping.confirm({ select = true }),
    ["<C-l>"] = cmp.mapping(snippets.forward, { "i", "s" }),
    ["<C-h>"] = cmp.mapping(snippets.backward, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    snippets.source,
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
