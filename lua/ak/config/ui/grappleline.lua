--          ╭─────────────────────────────────────────────────────────╮
--          │                       Grappleline                       │
--          ╰─────────────────────────────────────────────────────────╯
local Grappleline = require("grappleline")

-- HACK: For now, use boot.lazy with grapple, grappleline and lualine
-- local on_update = function() vim.wo.statusline = "%!v:lua.MiniStatusline.active()" end
local on_update = function() require("lualine").refresh() end

-- Extended
Grappleline.setup({
  override_scope_names = { git = "", git_branch = "dev" },
  on_update = on_update,
})

-- -- Short
-- Grappleline.setup({
--   override_scope_names = { git = "", git_branch = "dev" },
--   formatter = "short",
--   on_update = on_update,
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │               Grappleline test override:                │
--          ╰─────────────────────────────────────────────────────────╯

-- ---@type GrapplelineBuiltinOptionsExtended
-- local opts = {
--   indicators = { " j ", " k ", " l ", " h " },
--   active_indicators = { "<j>", "<k>", "<l>", "<h>" },
--   empty_slot = " · ",
-- }
-- Grappleline.setup({
--   custom_formatter = Grappleline.gen_override("extended", opts),
--   on_update = on_update,
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │                Grappleline test custom:                 │
--          ╰─────────────────────────────────────────────────────────╯

-- Grappleline.setup({
--   custom_formatter = Grappleline.gen_formatter(
--     ---@param data GrapplelineData
--     ---@return string
--     function(data)
--       return string.format(
--         "%s%s%s",
--         "➡️ ",
--         data.scope_name and string.format("%s ", data.scope_name) or "",
--         data.buffer_idx and string.format("%d", data.buffer_idx) or "-"
--       )
--     end
--   ),
--   on_update = on_update,
-- })
