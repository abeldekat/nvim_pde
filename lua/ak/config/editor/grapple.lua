--          ╭─────────────────────────────────────────────────────────╮
--          │                    Exploring Grapple                    │
--          ╰─────────────────────────────────────────────────────────╯

-- TODO: shift-enter does not work?
-- TODO: in grapple ui, highlight the line for the active buffer

local Grapple = require("grapple")
local P = require("grapple.path")
local H = {}

-- local default_order = { "global", "cwd", "git", "git_branch", "lsp" }
-- It's possible to use git and git_branch in the same way as two harpoon lists
-- git: the default list for the project
-- git_branch: the sublist for the current branch in the project
H.scopes = { "git", "git_branch" } -- global, static, cwd, git, git_branch, lsp
H.scope_default = H.scopes[1]
H.scope = H.scope_default

H.map = function(lhs, rhs, desc)
  --
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end
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

local opts = {
  scope = "git",
  icons = false,
  status = true,
  style = "basename",
  quick_select = "",
  styles = { -- override basename to always show the dir hint
    basename = function(entity, _)
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
    end,
  },
  win_opts = {
    style = "", --minimal disables a lot
  },
}

local keys = {
  -- { "<leader>J", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple toggle scopes" },
  { "<leader>J", H.use_scope, desc = "Use next or first scope" },

  { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
  { "<leader>j", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },

  -- { "<c-j>", function() G.select({ index = 1, scope = H.scope }) end, desc = "Select first tag" },
  { "<c-j>", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
  { "<c-k>", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
  { "<c-l>", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
  { "<c-h>", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },

  { "<leader>n", "<cmd>Grapple cycle forward<cr>", desc = "Grapple cycle forward" },
  { "<leader>p", "<cmd>Grapple cycle backward<cr>", desc = "Grapple cycle backward" },
}

for _, key in ipairs(keys) do
  H.map(key[1], key[2], key[3])
end
Grapple.setup(opts)
