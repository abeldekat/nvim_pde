--  Replaced by mini.visits...

-- Approach:
-- <leader>a toggles a tag in the current scope
--
-- Main scope is git. The first four files are on ctrl-{jklh}
--
-- Second scope is git_branch, called "dev". Used to collect multiple relevant files.
-- Tags can always be added using <leader>oa. Use ui to maintain its tags
--
-- Pick.registry.grapple provides fast labeled access to both scopes without needing
-- to change the current scope. See ak.config.editor.pick
--
-- See also ak.config.ui.grappleline

local Utils = require("ak.util")
local Grapple = require("grapple")
local P = require("grapple.path")

-- Helper:

local H = {}
H.scopes = Utils.labels.grapple
H.scope = H.scopes[1]

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

-- Setup:

local A = {
  switch_context = function()
    H.scope = H.name_of_next_scope()
    Grapple.use_scope(H.scope)
    vim.api.nvim_exec_autocmds("User", { pattern = "GrappleSwitchedContext", modeline = false, data = H.scope })
  end,
  ui = function() Grapple.toggle_tags() end,
  select = function(ind) Grapple.select({ index = ind }) end,
  toggle = function(scope)
    Grapple.toggle({ scope = scope })
    vim.api.nvim_exec_autocmds("User", { pattern = "GrappleModified", modeline = false })
  end,
  reset = function()
    Grapple.reset()
    vim.api.nvim_exec_autocmds("User", { pattern = "GrappleModified", modeline = false })
  end,
}

for _, key in ipairs({
  { "<leader>j", A.ui, desc = "Grapple ui" },
  { "<leader>a", function() A.toggle(H.label) end, desc = "Grapple toggle" },

  { "<c-j>", function() A.select(1) end, desc = "Grapple 1" },
  { "<c-k>", function() A.select(2) end, desc = "Grapple 2" },
  { "<c-l>", function() A.select(3) end, desc = "Grapple 3" },
  { "<c-h>", function() A.select(4) end, desc = "Grapple 4" },

  { "<leader>oa", function() A.toggle({ scope = H.scopes[#H.scopes] }) end, desc = "Grapple 'dev' toggle" },
  { "<leader>og", Grapple.toggle_scopes, desc = "Grapple scopes" },
  { "<leader>oj", A.switch_context, desc = "Grapple switch context" },
  { "<leader>or", A.reset, desc = "Grapple reset" },
}) do
  H.map(key[1], key[2], key["desc"])
end

Grapple.setup({
  scope = H.scope,
  icons = false,
  status = true,
  style = "basename",
  quick_select = "",
  styles = { basename = H.basename }, -- override basename to always show the dir hint
})
