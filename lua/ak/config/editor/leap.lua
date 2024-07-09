-- Not needed anymore: leap-spooky, telepath.nvim
-- https://www.reddit.com/r/neovim/comments/1dy5z0n/leapnvim_remote_operations_with_visual_feedback/

-- Notes from the help:
-- Initiate the search in the forward (`s`) or backward (`S`) direction, or in
-- the other windows (`gs`). (For different arrangements, see |leap-custom-mappings|.)
-- ...
-- Else: type the label character. If there are more matches than available
-- labels, you can switch between groups, using `<space>` and `<tab>`.
-- ..
-- At any stage (after 0, 1, or 2 input characters), `<enter>`
-- (|leap.opts.special_keys.next_target|) consistently jumps to the first
-- available target. Pressing it right after invocation (`s<enter>`) repeats the
-- previous search. Pressing it after one input character (`s{char}<enter>`) can
-- be used as a multiline substitute for `fFtT` motions.

local function leap_ts()
  local api = vim.api
  local ts = vim.treesitter

  local function get_ts_nodes()
    if not pcall(ts.get_parser) then return end
    local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
    -- Get current node, and then its parent nodes recursively.
    local cur_node = ts.get_node()
    if not cur_node then return end
    local nodes = { cur_node }
    local parent = cur_node:parent()
    while parent do
      table.insert(nodes, parent)
      parent = parent:parent()
    end
    -- Create Leap targets from TS nodes.
    local targets = {}
    local startline, startcol, endline, endcol
    for _, node in ipairs(nodes) do
      startline, startcol, endline, endcol = node:range() -- (0,0)
      local startpos = { startline + 1, startcol + 1 }
      local endpos = { endline + 1, endcol + 1 }
      -- Add both ends of the node.
      if startline + 1 >= wininfo.topline then table.insert(targets, { pos = startpos, altpos = endpos }) end
      if endline + 1 <= wininfo.botline then table.insert(targets, { pos = endpos, altpos = startpos }) end
    end
    if #targets >= 1 then return targets end
  end

  local function select_node_range(target)
    local mode = api.nvim_get_mode().mode
    -- Force going back to Normal from Visual mode.
    if not mode:match("no?") then vim.cmd("normal! " .. mode) end
    vim.fn.cursor(unpack(target.pos))
    local v = mode:match("V") and "V" or mode:match("�") and "�" or "v"
    vim.cmd("normal! " .. v)
    vim.fn.cursor(unpack(target.altpos))
  end

  require("leap").leap({
    target_windows = { api.nvim_get_current_win() },
    targets = get_ts_nodes,
    action = select_node_range,
  })
end

--          ╭─────────────────────────────────────────────────────────╮
--          │                          Leap                           │
--          ╰─────────────────────────────────────────────────────────╯
-- Bidirectional search in the current window
-- ... You cannot traverse through the matches (|leap-traversal|),
-- although invoking repeat right away (|leap-repeat|) can substitute for that
vim.keymap.set("n", "s", "<Plug>(leap)", { desc = "Leap" })
vim.keymap.set("n", "S", "<Plug>(leap-from-window)", { desc = "Leap in windows" })
vim.keymap.set({ "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
vim.keymap.set({ "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
vim.keymap.set({ "x", "o" }, "\\", leap_ts)

require("leap").opts.preview_filter = function(ch0, ch1, ch2)
  -- Input: the match and its immediate context as argument.
  -- Hide e.g. whitespace and alphanumeric mid-word positions:
  -- You can still target any visible positions if needed,
  -- but you can define what is considered an exceptional case ("don't bother me with preview for them")
  return not (ch1:match("%s") or ch0:match("%w") and ch1:match("%w") and ch2:match("%w"))
end

--          ╭─────────────────────────────────────────────────────────╮
--          │  Leap remote: gs and gS cannot be used(mini.operators)  │
--          ╰─────────────────────────────────────────────────────────╯
-- Dynamic:
-- Example: 'g/{leap}ipy' (inside paragraph) -- operation last, visual mode in the remote
-- Example: 'yg/{leap}ip' (inside paragraph) -- operation first, no visual mode
-- Example: Using flash: 'yr{flash}ip' (inside paragraph)
vim.keymap.set({ "n" }, "g/", function() require("leap.remote").action() end, { desc = "Leap remote" })

-- In operator pending mode, "r" is shorter than "g/":
vim.keymap.set({ "o" }, "g/", function() require("leap.remote").action() end, { desc = "Leap remote" })
-- Flash -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
vim.keymap.set({ "o" }, "r", function() require("leap.remote").action() end, { desc = "Leap remote" })
-- Example: forced linewise version:
-- vim.keymap.set({ "n", "o" }, "gS", function() require("leap.remote").action({ input = "V" }) end)

vim.api.nvim_create_augroup("LeapRemote", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "RemoteOperationDone",
  group = "LeapRemote",
  callback = function(event)
    -- Do not paste if some special register was in use.
    local expected_register = "+" -- "-"
    if vim.v.operator == "y" and event.data.register == expected_register then vim.cmd("normal! p") end
  end,
})

--          ╭─────────────────────────────────────────────────────────╮
--          │                Leap remote alternatives                 │
--          ╰─────────────────────────────────────────────────────────╯

-- 1 solution ggandor:
-- -- Not needed, one can also use "ir/ar", or "r"
-- -- Static: Predefined remote text objects
-- -- Example: 'yarp{leap}'
-- local predefined_remotes = {
--   'iw', 'iW', 'is', 'ip', 'i[', 'i]', 'i(', 'i)', 'ib',
--   'i>', 'i<', 'it', 'i{', 'i}', 'iB', 'i"', 'i\'', 'i`',
--   'aw', 'aW', 'as', 'ap', 'a[', 'a]', 'a(', 'a)', 'ab',
--   'a>', 'a<', 'at', 'a{', 'a}', 'aB', 'a"', 'a\'', 'a`',
-- }
-- for _, text_obj in ipairs(predefined_remotes) do
--   local lhs = text_obj:sub(1, 1) .. "r" .. text_obj:sub(2)
--   vim.keymap.set(
--     { "x", "o" },
--     lhs,
--     function() require("leap.remote").action({ input = text_obj }) end,
--     { desc = "Leap remote " .. lhs }
--   )
-- end

-- 2 Reddit, solution TheLeoP_:
-- All one letter text-objects can be mapped with a single keymap like:
-- Disadvantage: cannot use "s" to search in the remote: yir{required textobject one letter}{leap}
-- vim.keymap.set({ "x", "o" }, "ir", function()
--   local ok, char = pcall(vim.fn.getcharstr)
--   if not ok or char == "\27" or not char then return end
--   require("leap.remote").action({ input = "i" .. char })
-- end, { desc = "Leap remote" })
-- vim.keymap.set({ "x", "o" }, "ar", function()
--   local ok, char = pcall(vim.fn.getcharstr)
--   if not ok or char == "\27" or not char then return end
--   require("leap.remote").action({ input = "a" .. char })
-- end, { desc = "Leap remote" })
