-- https://taplo.tamasfe.dev/
-- Arch linux: sudo pacman -S taplo
-- Can also be installed via cargo

return {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
}
