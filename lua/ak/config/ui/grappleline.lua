--          ╭─────────────────────────────────────────────────────────╮
--          │                       Grappleline                       │
--          ╰─────────────────────────────────────────────────────────╯
local Grappleline = require("grappleline")

-- HACK: For now, use boot.lazy with grapple, grappleline and lualine
local on_update = function() require("lualine").refresh() end

-- Extended
Grappleline.setup({
  override_scope_names = { git = "", git_branch = "dev" },
  on_update = on_update,
})

-- -- Short
-- Grappleline.setup({
--   formatter = "short",
--   on_update = on_update,
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │               Grappleline test override:                │
--          ╰─────────────────────────────────────────────────────────╯

-- ---@type GrapplelineBuiltinOptionsExtended
-- local opts = {
--   -- indicators = { "j", "k", "l", "h" },
--   -- active_indicators = { "<j>", "<k>", "<l>", "<h>" },
--   -- separator = " ",
--   -- empty_slot = "",
--   -- more_marks_indicator = "",
--   -- more_marks_active_indicator = "",
-- }
-- Grappleline.setup({
--   custom_formatter = Grappleline.gen_override("extended", opts),
--   on_update = on_update
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
--         data.list_name and string.format("%s ", data.list_name) or "",
--         data.buffer_idx and string.format("%d", data.buffer_idx) or "-"
--       )
--     end
--   ),
--   on_update = on_update
-- })
