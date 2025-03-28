-- https://github.com/artempyanykh/marksman
-- Using mason. Arch linux: sudo pacman -S marksman

local bin_name = "marksman"
local cmd = { bin_name, "server" }

return {
  cmd = cmd,
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
}
