-- Use fuzzy matching provided by blink.cmp
-- The differences with mini.completion:
-- 1. fuzzy is only called when lsp is called, instead of on each keystroke.
-- 2. When fuzzy is not called, neovim internal "fuzzy" is used.

local CompletionBlinked = {}
local H = {}

-- Only "rust" provides frecency...
local blink_impl = "rust" -- with "lua", the rust binary will not be downloaded...
local blink_config = require("blink.cmp.config")
local blink_fuzzy = require("blink.cmp.fuzzy")

CompletionBlinked.setup = function()
  _G.CompletionBlinked = CompletionBlinked

  -- The relevant parts in blink.cmp.init.setup:
  blink_config.merge_with({ fuzzy = { implementation = blink_impl } })
  require("blink.cmp.fuzzy.download").ensure_downloaded(function(err, fuzzy_implementation)
    if err then return vim.notify(err, vim.log.levels.ERROR) end
    blink_fuzzy.set_implementation(fuzzy_implementation)
  end)

  vim.api.nvim_create_autocmd("CompleteDone", { -- add to blink's db, frecency
    group = vim.api.nvim_create_augroup("ak_miniblink_completion", {}),
    pattern = "*",
    callback = function()
      local lsp_data = H.table_get(vim.v.completed_item, { "user_data", "lsp", "item" })
      if lsp_data then
        -- struct CompletionItemKey { label: String, kind: u32, source_id: String, }
        -- Field source_id is not needed, only one source is used...
        -- lsp_data["source_id"] = "lsp" -- add missing key data. Label and kind are present.
        --
        blink_fuzzy.access(lsp_data)
      end
    end,
  })
end

CompletionBlinked.fuzzy = function(items, base)
  -- Blink uses the whole current line.
  -- Using native completion, in ctrl-x mode, base is not part of line...
  -- local line = H.context_get_line()
  -- local cursor = H.context_get_cursor()
  local line = base
  local cursor = #base

  return blink_fuzzy.fuzzy( -- see the call in blink.cmp.completion.list.fuzzy
    line,
    cursor,
    { lsp = items }, -- the haystack...
    blink_config.completion.keyword.range
  )
end

H.table_get = function(t, id) -- copied from mini.completion...
  if type(id) ~= "table" then return H.table_get(t, { id }) end
  local success, res = true, t
  for _, i in ipairs(id) do
    success, res = pcall(function() return res[i] end)
    if not success or res == nil then return end
  end
  return res
end

-- Does not work with native completion...
H.context_get_cursor = function() -- modified from blink.cmp.completion.trigger.context
  return vim.api.nvim_win_get_cursor(0)
end
-- Does not work with native completion...
H.context_get_line = function(num) -- modified from blink.cmp.completion.trigger.context
  if num == nil then num = H.context_get_cursor()[1] - 1 end
  return vim.api.nvim_buf_get_lines(0, num, num + 1, false)[1]
end

return CompletionBlinked
