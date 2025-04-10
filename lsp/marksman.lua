-- https://github.com/artempyanykh/marksman
-- Arch linux: sudo pacman -S marksman markdownlint-cli2
-- Marksman needs the dotnet runtime
-- Also useful: markdown-toc, npm install --save markdown-toc, https://github.com/jonschlinkert/markdown-toc

local bin_name = "marksman"
local cmd = { bin_name, "server" }

return {
  cmd = cmd,
  filetypes = { "markdown", "markdown.mdx" },
  root_markers = { ".marksman.toml", ".git" },
}
