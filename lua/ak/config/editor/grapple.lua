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
  vim.opt_local.number = true -- window style is minimal
  vim.opt.relativenumber = true

  local parent_mark -- avoid a line containing "init.lua init.lua":
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
  { "<leader>J", H.use_scope, desc = "Grapple other scope" },
  { "<leader>j", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple tags" },
  -- Not useing next and prev often:
  -- { "<leader>;", "<cmd>Grapple cycle_tags next<cr>", desc = "Grapple next" },
  -- { "<leader>,", "<cmd>Grapple cycle_tags prev<cr>", desc = "Grapple prev" },

  { "<leader>A", "<cmd>Grapple reset<cr>", desc = "Grapple reset" },
  { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Grapple toggle tag" },

  { "<c-j>", "<cmd>Grapple select index=1<cr>", desc = "Grapple 1" },
  { "<c-k>", "<cmd>Grapple select index=2<cr>", desc = "Grapple 2" },
  { "<c-l>", "<cmd>Grapple select index=3<cr>", desc = "Grapple 3" },
  { "<c-h>", "<cmd>Grapple select index=4<cr>", desc = "Grapple 4" },

  { "<leader>og", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple scopes" },
  { "<leader>oG", "<cmd>Grapple toggle_loaded<cr>", desc = "Grapple loaded" },
}) do
  H.map(key[1], key[2], key["desc"])
end

Grapple.setup({
  scope = "git",
  icons = false,
  status = true,
  style = "basename",
  quick_select = "",
  -- -- override basename to always show the dir hint
  styles = { basename = H.basename },
})
