local function custom_formatter(opts_in, data)
  local opts = { -- condensed line showing 4 slots and an optional extra slot
    max_slots = 4,
    inactive = "%s",
    active = "[%s]",
    empty_slot = "·", -- #slots > #tags, middledot
    more_marks_indicator = "…", -- #slots < #tags, horizontal elipsis
  }
  if data.scope_name == "git" then
    data.scope_name = ""
  elseif data.scope_name == "git_branch" then
    data.scope_name = "dev"
  end

  local status = {} -- build slots:
  local max_tags = #data.tags
  local current_path = data.current and data.current.path or nil
  for i = 1, opts.max_slots do
    local tag_fmt = opts.inactive
    local tag_str = "" .. i
    if i > max_tags then -- more slots then ...
      tag_str = opts.empty_slot
    else
      local tag = data.tags[i]
      if current_path == tag.path then tag_fmt = opts.active end
    end
    table.insert(status, string.format(tag_fmt, tag_str))
  end
  if max_tags > opts.max_slots then -- more marks then... One indicator
    local tag_fmt = opts.inactive
    local tag_str = opts.more_marks_indicator
    if current_path then
      for i = opts.max_slots + 1, max_tags do
        local tag = data.tags[i]
        if current_path == tag.path then
          tag_fmt = opts.active
          break
        end
      end
    end
    table.insert(status, string.format(tag_fmt, tag_str))
  end

  local prefix = string.format("%s%s%s", opts_in.icon, data.scope_name == "" and "" or " ", data.scope_name)
  return prefix .. " " .. table.concat(status)
end

local Grapple = require("grapple")
local P = require("grapple.path")
local H = {} -- helper functions

--          ╭─────────────────────────────────────────────────────────╮
--          │                       Helper data                       │
--          ╰─────────────────────────────────────────────────────────╯
-- local default_order = { "global", "cwd", "git", "git_branch", "lsp" }
-- It's possible to use git and git_branch in the same way as two harpoon lists
-- git: the default list for the project
-- git_branch: the sublist for the current branch in the project
H.scopes = { "git", "git_branch" } -- global, static, cwd, git, git_branch, lsp
H.scope_default = H.scopes[1]
H.scope = H.scope_default

--          ╭─────────────────────────────────────────────────────────╮
--          │                    Helper functions                     │
--          ╰─────────────────────────────────────────────────────────╯
H.map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end
H.name_of_next_scope = function()
  local function current_scope()
    for idx, name in ipairs(H.scopes) do
      if name == H.scope then return idx end
    end
  end
  local idx = current_scope()
  return H.scopes[idx == #H.scopes and 1 or idx + 1]
end
H.use_scope = function()
  H.scope = H.name_of_next_scope()
  vim.cmd("Grapple use_scope " .. H.scope)
end
H.basename = function(entity, _)
  vim.opt_local.cursorline = false
  vim.b.minicursorword_disable = true

  local parent_mark
  -- avoid a line containing "init.lua init.lua":
  local use_virtual_txt = P.fs_short(entity.tag.path) ~= P.base(entity.tag.path)
  if use_virtual_txt then
    parent_mark = {
      virt_text = {
        { P.fs_short(entity.tag.path), "GrappleHint" },
      },
      virt_text_pos = "eol",
    }
  end
  return { -- the line
    display = P.base(entity.tag.path),
    marks = { parent_mark },
  }
end

for _, key in ipairs({
  { "<leader>J", H.use_scope, desc = "Grapple next scope" },

  { "<leader>j", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple tags" },
  { "<leader>n", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple next" },
  { "<leader>p", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple prev" },

  { "<leader>A", "<cmd>Grapple reset<cr>", desc = "Grapple reset" },
  { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle" },

  { "<c-j>", "<cmd>Grapple select index=1<cr>", desc = "Grapple 1" },
  { "<c-k>", "<cmd>Grapple select index=2<cr>", desc = "Grapple 2" },
  { "<c-l>", "<cmd>Grapple select index=3<cr>", desc = "Grapple 3" },
  { "<c-h>", "<cmd>Grapple select index=4<cr>", desc = "Grapple 4" },

  { "<leader>mg", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple scopes" },
  { "<leader>mG", "<cmd>Grapple toggle_loaded<cr>", desc = "Grapple loaded" },
}) do
  H.map(key[1], key[2], key["desc"])
end

Grapple.setup({
  scope = "git",
  icons = false,
  status = true,
  style = "basename",
  quick_select = "",
  -- override basename to always show the dir hint
  styles = { basename = H.basename },
  --"minimal" style disables a lot. Make it look like harpoon...
  win_opts = { style = "" },
  statusline = {
    formatter = custom_formatter,
  },
})