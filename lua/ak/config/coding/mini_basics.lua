--          ╭─────────────────────────────────────────────────────────╮
--          │           A copy of MiniBasics functionality            │
--          ╰─────────────────────────────────────────────────────────╯

-- gO:
-- gO			Show a filetype-specific, navigable "outline" of the
-- 			current buffer. For example, in a |help| buffer this
-- 			shows the table of contents.

-- go:
-- :[range]go[to] [count]					*:go* *:goto* *go*
-- [count]go		Go to [count] byte in the buffer.

local H = {} -- mimic MiniBasics

-- Add empty lines before and after cursor line supporting dot-repeat
H.put_empty_line = function(put_above)
  -- This has a typical workflow for enabling dot-repeat:
  -- - On first call it sets `operatorfunc`, caches data, and calls
  --   `operatorfunc` on current cursor position.
  -- - On second call it performs task: puts `v:count1` empty lines
  --   above/below current line.
  if type(put_above) == "boolean" then
    vim.o.operatorfunc = "v:lua.MiniBasics.put_empty_line"
    H.cache_empty_line = { put_above = put_above }
    return "g@l"
  end

  local target_line = vim.fn.line(".") - (H.cache_empty_line.put_above and 1 or 0)
  vim.fn.append(target_line, vim.fn["repeat"]({ "" }, vim.v.count1))
end

-- if you don't want to support dot-repeat, use this snippet:
-- ```
-- map('n', 'gO', "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>")
-- map('n', 'go', "<Cmd>call append(line('.'),     repeat([''], v:count1))<CR>")
-- ```
vim.keymap.set("n", "gO", "v:lua.MiniBasics.put_empty_line(v:true)", { expr = true, desc = "Put empty line above" })
vim.keymap.set("n", "go", "v:lua.MiniBasics.put_empty_line(v:false)", { expr = true, desc = "Put empty line below" })

-- Export module
_G.MiniBasics = H
