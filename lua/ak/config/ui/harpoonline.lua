--          ╭─────────────────────────────────────────────────────────╮
--          │                       Harpoonline                       │
--          ╰─────────────────────────────────────────────────────────╯
local Harpoonline = require("harpoonline")

local on_update = function() vim.wo.statusline = "%!v:lua.MiniStatusline.active()" end

-- Extended
Harpoonline.setup({
  on_update = on_update,
})

-- -- Short
-- Harpoonline.setup({
--   formatter = "short",
--   on_update = on_update
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │               Harpoonline test override:                │
--          ╰─────────────────────────────────────────────────────────╯

-- ---@type HarpoonlineBuiltinOptionsExtended
-- local opts = {
--   -- indicators = { "j", "k", "l", "h" },
--   -- active_indicators = { "<j>", "<k>", "<l>", "<h>" },
--   -- separator = " ",
--   -- empty_slot = "",
--   -- more_marks_indicator = "",
--   -- more_marks_active_indicator = "",
-- }
-- Harpoonline.setup({
--   custom_formatter = Harpoonline.gen_override("extended", opts),
--   on_update = on_update
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │                Harpoonline test custom:                 │
--          ╰─────────────────────────────────────────────────────────╯

-- Harpoonline.setup({
--   custom_formatter = Harpoonline.gen_formatter(
--     ---@param data HarpoonLineData
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
