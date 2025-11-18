local ext3_blocklist = { scm = true, txt = true, yml = true }
local ext4_blocklist = { json = true, yaml = true }
require('mini.icons').setup({
  use_file_extension = function(ext, _) return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)]) end,
})

-- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
-- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
-- later(MiniIcons.mock_nvim_web_devicons)
