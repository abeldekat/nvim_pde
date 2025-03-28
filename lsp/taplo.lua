-- https://taplo.tamasfe.dev/
-- Using Mason. Arch linux: sudo pacman -S taplo
-- Can be installed via cargo

return {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
}
