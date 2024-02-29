--          ╭─────────────────────────────────────────────────────────╮
--          │                     :h leap-config                      │
--          ╰─────────────────────────────────────────────────────────╯

--          ╭─────────────────────────────────────────────────────────╮
--          │                :h leap-default-mappings                 │
--          ╰─────────────────────────────────────────────────────────╯
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward", silent = true })
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward", silent = true })
--          ╭─────────────────────────────────────────────────────────╮
--          │     gs is occupied by mini.operators: go substitute     │
--          ╰─────────────────────────────────────────────────────────╯
vim.keymap.set({ "n", "x", "o" }, "g/", "<Plug>(leap-from-window)", { desc = "Leap from window", silent = true })

--          ╭─────────────────────────────────────────────────────────╮
--          │     The following additional tweaks are suggested:      │
--          ╰─────────────────────────────────────────────────────────╯
require("leap").opts.special_keys.prev_group = "<bs>"
require("leap").opts.special_keys.prev_target = "<bs>"
require("leap.user").set_repeat_keys("<cr>", "<bs>")

--          ╭─────────────────────────────────────────────────────────╮
--          │      https://github.com/neovim/neovim/issues/20793      │
--          │Workaround for the duplicate cursor bug when autojumping │
--          ╰─────────────────────────────────────────────────────────╯
-- Confusing...
-- Hide the (real) cursor when leaping, and restore it afterwards.
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LeapEnter",
--   callback = function()
--     vim.cmd.hi("Cursor", "blend=100")
--     vim.opt.guicursor:append({ "a:Cursor/lCursor" })
--   end,
-- })
-- vim.api.nvim_create_autocmd("User", {
--   pattern = "LeapLeave",
--   callback = function()
--     vim.cmd.hi("Cursor", "blend=0")
--     vim.opt.guicursor:remove({ "a:Cursor/lCursor" })
--   end,
-- })

--          ╭─────────────────────────────────────────────────────────╮
--          │                    treesitter nodes:                    │
--          ╰─────────────────────────────────────────────────────────╯
local H = {}
function H.leap_ts()
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
vim.keymap.set({ "x", "o" }, "\\", H.leap_ts)

--          ╭─────────────────────────────────────────────────────────╮
--          │                      leap-spooky:                       │
--          │                  No :h, see the readme                  │
--          ╰─────────────────────────────────────────────────────────╯
--     -- The cursor moves to the targeted object, and stays there:
--     magnetic = { window = "m", cross_window = "M" },
--     -- The cursor boomerangs back afterwards:
--     remote = { window = "r", cross_window = "R" },
--
-- Note: leap-spooky is less powerfull than flash "yr"
-- using flash, "yr" first needs the reach the target,
-- after which any textobject/motion(including a flash motion) can be specified.
-- leap-spooky needs the textobject upfront
-- Custom textobjects need to be added to the config in order to be usable
require("leap-spooky").setup({
  extra_text_objects = nil, -- the default
  prefix = true, -- yriw instead of yirw
})
