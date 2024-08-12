-- Approach:
-- <leader>a toggles a tag in the current scope
--
-- Main scope is git. The first four files are on ctrl-{jklh}
-- When git is current, tags can be toggled using <leader>a, so the ui is rarely needed.
--
-- Second scope is git_branch, called "dev". Used to collect multiple relevant files.
-- Tags can always be added using <leader>oa. Use ui to maintain its tags
--
-- Pick.registry.grapple provides fast labeled access to both scopes without needing
-- to change the current scope. See ak.config.editor.pick
--
-- See also ak.config.ui.grappleline

-- local default_order = { "global", "cwd", "git", "git_branch", "lsp" }
local Grapple = require("grapple")
local P = require("grapple.path")
local H = {} -- helper

H.scopes = { "git", "git_branch" } -- global, static, cwd, git, git_branch, lsp
H.scope_default = H.scopes[1]
H.scope = H.scope_default

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
-- When switching scopes, also show the ui. Fast repeat with <leader>oj
H.use_scope_and_open_ui = function()
  H.scope = H.name_of_next_scope()
  vim.cmd("Grapple use_scope " .. H.scope)
  Grapple.open_tags()
end

for _, key in ipairs({
  { "<leader>j", "<cmd>Grapple toggle_tags<cr>", desc = "Grapple ui" },
  { "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Grapple tag +-" },

  { "<c-j>", "<cmd>Grapple select index=1<cr>", desc = "Grapple 1" },
  { "<c-k>", "<cmd>Grapple select index=2<cr>", desc = "Grapple 2" },
  { "<c-l>", "<cmd>Grapple select index=3<cr>", desc = "Grapple 3" },
  { "<c-h>", "<cmd>Grapple select index=4<cr>", desc = "Grapple 4" },

  { "<leader>oa", function() Grapple.tag({ scope = "git_branch" }) end, desc = "Grapple tag dev +" },
  { "<leader>og", "<cmd>Grapple toggle_scopes<cr>", desc = "Grapple scopes" },
  { "<leader>oj", H.use_scope_and_open_ui, desc = "Grapple main <-> dev" },
  { "<leader>or", "<cmd>Grapple reset<cr>", desc = "Grapple reset" },
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
