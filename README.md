# Neovim pde

My _personal development environment_ for Neovim

## Older versions

> [!NOTE]
> Tag [with_submodules] references the version containing `git submodules`,
> `lazy.nvim` and `mini.deps`
>
> Tag [with_lazynvim] references the version containing `lazy.nvim` and `mini.deps`

### Structure

- `init`: Uses `:h vim.loader` and calls `ak.init`
- [ak.init]: Invoke [ak.mini_deps]
- [ak.deps]: Load plugins
- [ak.config]: All setup for plugins, options, key-mappings, auto-commands, and colors
- [ak.util]: Shared code

## Install

> Requirements: Neovim latest version or nightly.
>
> Always review the code before trying a configuration.

Clone the repository:

```sh
git clone https://github.com/abeldekat/nvim_pde ~/.config/ak
```

Open Neovim with this config, installing the plugins:

```sh
NVIM_APPNAME=ak nvim
```

Remove the config:

```sh
rm -rf ~/.local/share/ak ~/.local/state/ak ~/.cache/ak
rm -rf ~/.config/ak
```

Note: For [peek.nvim], [deno] needs to be installed.

## Workflow

I touch type using the right hand
in combination with the forefinger of the left hand

Leader: `space`

### Navigation

- Main plugins: grapple, oil, mini.pick and mini.jump2d.
- Menu: `mini.clue`

#### Grapple

- Switch active list: `<leader>J`
- Info in statusline: custom statusline component [grappleline]
- Using the shortcuts for window navigation:
  `c-j`, `<c-k>`,`<c-l>`,`<c-h>`, corresponding to file 1-4
- ui: `<leader>j` ("strongest finger")
- toggle tag: `<leader>a`
- next/prev: `<leader>;` / `<leader>,`

Window navigation:

- `<c-w>hjkl` (stock `Neovim`)
- `mw`(next window)
- `me`(last accessed window)

#### Oil

- `mk`("rolling fingers"), opening oil
- `h` up one level
- `l` down one level, open file

#### Tmux

- [tmux-sessionizer] inspired by @ThePrimeagen
- workspaces at the top of the screen, using [tmuxp]
- leader: `ctrl space`
- navigation:
  - `tmux-sessionizer`: leader h
  - previous session: leader j
  - previous window: leader l
  - existing sessions: leader k
  - switch pane: leader o

### UI

- `mini.statusline`, no colors, except on:
  - mode change
  - diagnostics
  - current buffer is tagged(grapple)
  - macro recording
- many color-schemes

Change color-schemes:

- on each startup, see [scripts], `vim_menu_owns`
- mini.pick, `leader f o c`, loads all colors, does not show builtin color-schemes
- change the palette of the current color-scheme using [leader h]

Script `vim_menu_owns` writes to `lua.ak.colors`.
Ignoring changes to that file:

```sh
git update-index --assume-unchanged lua/ak/colors.lua
```

### Key conflicts

Replace **replace** with **substitute** mnemonic:

In my config, the suggested key `gr`("go replace") in [mini.operators] is already used
for the `lsp`("go references").
I prefer "two character hotkeys" as I use some lsp keys quite often(`gd`, `gr`).
Solution: Change operator `gr` into `gs`, mnemonic for "go substitute".

Consequences:

- [mini.operators]: Change suggested key `gs`("go sort") into `gS`.
- [mini.surround]: Change `sr`(surround replace) into `ss`(surround substitute).

## Environment

[tmux](https://github.com/abeldekat/tmux)
[alacritty](https://github.com/abeldekat/alacritty)
[zsh](https://github.com/abeldekat/zsh)
[scripts](https://github.com/abeldekat/scripts)
[awesome](https://github.com/abeldekat/awesome)
[arch linux](https://archlinux.org/)

## Acknowledgements

This repo uses code and ideas from the following repositories:

- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [mini.deps](https://github.com/echasnovski/mini.deps)
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [dotfiles](https://github.com/folke/dot/tree/master/nvim) `@folke`
- [dotfiles](https://github.com/dpetka2001/dotfiles/tree/main/dot_config/nvim) `@dpetka2001`
- [dotfiles](https://github.com/lewis6991/dotfiles/tree/main/config/nvim) `@lewis6991`
- [dotfiles](https://github.com/savq/dotfiles/tree/master/nvim) `@savq`
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)

[tmuxp]: https://github.com/tmux-python/tmuxp
[scripts]: https://github.com/abeldekat/scripts
[tmux-sessionizer]: https://github.com/abeldekat/scripts/blob/main/tmux-sessionizer
[ak.init]: lua/ak/init.lua
[ak.mini_deps]: lua/ak/mini_deps.lua
[ak.deps]: lua/ak/deps
[ak.config]: lua/ak/config
[ak.util]: lua/ak/util
[grappleline]: lua/ak/config/ui/grappleline.lua
[leader h]: lua/ak/util/color.lua
[mini.operators]: https://github.com/echasnovski/mini.operators
[mini.surround]: https://github.com/echasnovski/mini.surround
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
