# LSP

Tools used without lsp:
prettier, arch linux: `sudo pacman -S prettier`

## bash

[github](https://github.com/bash-lsp/bash-language-server)
Arch linux: `sudo pacman -S bash-language-server shfmt shellcheck`

## go

[github](https://github.com/golang/tools/tree/master/gopls)
[gopls](https://pkg.go.dev/golang.org/x/tools/gopls)
Arch linux: `sudo pacman -S gopls gofumpt`

Perhaps use `goimports`:
[goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports)

> A golang formatter which formats your code in the same style as gofmt and additionally
> updates your Go import lines, adding missing ones and removing unreferenced ones.

## json

[microsoft](https://github.com/microsoft/vscode-json-languageservice)
[github extracted](https://github.com/hrsh7th/vscode-langservers-extracted)

Install via aur:

- `git clone https://aur.archlinux.org/vscode-langservers-extracted.git`
- `cd and makepkg -si, essentially doing a npm install`

```txt
vscode-langservers-extracted /usr/bin/vscode-css-language-server
vscode-langservers-extracted /usr/bin/vscode-eslint-language-server
vscode-langservers-extracted /usr/bin/vscode-html-language-server
vscode-langservers-extracted /usr/bin/vscode-json-language-server
vscode-langservers-extracted /usr/bin/vscode-markdown-language-server
```

Can also be installed with `npm i -g vscode-langservers-extracted`
See also in `mason-registry`: `packages/json-lsp/package.yaml`

## lua

[github](https://github.com/luals/lua-language-server)
Arch linux: `sudo pacman -S lua-language-server stylua`

## latex

[github](https://github.com/latex-lsp/texlab)
Arch linux: `sudo pacman -S texlab`

## markdown

[github](https://github.com/artempyanykh/marksman)
Arch linux: `sudo pacman -S marksman markdownlint-cli2`
Marksman needs the `dotnet`runtime.
Also useful: [markdown-toc](https://github.com/jonschlinkert/markdown-toc)
`npm install --save markdown-toc`

## python

[basedpyright](https://github.com/detachhead/basedpyright)
Installed with pipx. Alternatively use pip locally.

[ruff](https://github.com/astral-sh/ruff/)
Arch linux: `sudo pacman -S ruff`

`sudo pacman -S python-black`

Installed on 20250411:
`python-mypy_extensions-1.0.0-5 python-pathspec-0.12.1-3 python-black-25.1.0-1`

## rust

Install rust with rustup script. Also possible with `sudo pacman -S rustup`

[github](https://rust-analyzer.github.io/)
Install rust-analyzer with cargo

Debugger:
[github](https://github.com/vadimcn/codelldb)

> A native debugger extension for vscode based on lldb

[aur](https://aur.archlinux.org/packages/codelldb-bin)
version 1.11.0 on 20250411, version 1.11.4 with mason on 20250411

- `git clone https://aur.archlinux.org/codelldb-bin.git/`
- `cd and makepkg -si`, essentially fetching the release from github

Also see `mason-registry`: `packages/codelldb/package.yaml`

## toml

[info](https://taplo.tamasfe.dev/)
Arch linux: `sudo pacman -S taplo`
Can also be installed via cargo

## yaml

[redhat](https://github.com/redhat-developer/yaml-language-server)
Arch linux: `sudo pacman -S yaml-language-server`

## zig

[github](https://github.com/zigtools/zls)
Arch linux: `sudo pacman -S zls`

Installed on 20250411:
`clang18-18.1.8-1  compiler-rt18-18.1.8-1  lld18-18.1.6-2  llvm18-libs-18.1.8-1  zig-0.13.0-2  zls-0.13.0-1`
