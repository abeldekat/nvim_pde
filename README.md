# Neovim pde

My _personal development environment_ for Neovim

## Older versions

> [!NOTE]
> Tag [with_submodules] references the version containing `git submodules`,
> `lazy.nvim` and `mini.deps`
>
> Tag [with_lazynvim] references the version containing `lazy.nvim` and `mini.deps`

### Structure

- `init`: Defers to `ak.init`. Uses `:h vim.loader`.
- `ak.init`: Bootstrap [mini.deps] using [ak.boot.deps]
- [ak.deps]: Contains specs for [mini.deps] that load the config in `ak.config`
- [ak.config]: Contains all setup for options, key-mappings, auto-commands,
  color-schemes and plugins.
- [ak.util]: Shared code.

## Install

> Requirements: Neovim latest version or nightly.
>
> Always review the code before installing a configuration.

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

- Main plugins: grapple, oil and telescope.
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

- `ml`("rolling fingers"), opening oil
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
- `cmdheight 0`
- many color-schemes

Change color-schemes:

- on each startup, see [scripts], `vim_menu_owns`
- telescope, [leader uu], loads all colors, does not show builtin color-schemes
- change the palette of the current color-scheme using [leader h], aka "hue"

Script `vim_menu_owns` writes to `lua.ak.colors`.
Ignoring changes to that file:

```sh
git update-index --assume-unchanged lua/ak/colors.lua
```

### Key conflicts

_Surrounding_:

Using [mini.surround]. Suggested keys: `sa sd sr sf sF sh sn`

The "s" is already used by [leap.nvim].
Solution: Use the `m` key in combination with `asdf`,
adjacent keys on a qwerty keyboard.
Key `ms` is a mnemonic for `surround substitute`, performing a surround replace.

_Operators_:

Using [mini.operators]. Suggested key `gr`("go replace")
is already used by the `lsp`("go references").
Solution: Use `gs`, mnemonic for "go substitute".
Change suggested key `gs`("go sort") into `gS`.

## Environment

[tmux](https://github.com/abeldekat/tmux)
[alacritty](https://github.com/abeldekat/alacritty)
[zsh](https://github.com/abeldekat/zsh)
[scripts](https://github.com/abeldekat/scripts)
[awesome](https://github.com/abeldekat/awesome)
[arch linux](https://archlinux.org/)

## Acknowledgements

This repo uses code and ideas from the following repositories:

- [mini.deps](https://github.com/echasnovski/mini.deps)
- [lazy.nvim](https://github.com/folke/lazy.nvim)
- [pckr.nvim](https://github.com/lewis6991/pckr.nvim)
- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [dotfiles](https://github.com/folke/dot/tree/master/nvim) `@folke`
- [dotfiles](https://github.com/dpetka2001/dotfiles/tree/main/dot_config/nvim) `@dpetka2001`
- [dotfiles](https://github.com/lewis6991/dotfiles/tree/main/config/nvim) `@lewis6991`
- [dotfiles](https://github.com/savq/dotfiles/tree/master/nvim) `@savq`
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`

[mini.deps]: https://github.com/echasnovski/mini.deps
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[tmuxp]: https://github.com/tmux-python/tmuxp
[scripts]: https://github.com/abeldekat/scripts
[tmux-sessionizer]: https://github.com/abeldekat/scripts/blob/main/tmux-sessionizer
[ak.boot.deps]: lua/ak/boot/deps.lua
[ak.deps]: lua/ak/deps
[ak.config]: lua/ak/config
[ak.util]: lua/ak/util
[grappleline]: lua/ak/config/ui/grappleline.lua
[leader uu]: lua/ak/util/color.lua
[leader h]: lua/ak/util/color.lua
[mini.surround]: https://github.com/echasnovski/mini.surround
[mini.operators]: https://github.com/echasnovski/mini.operators
[leap.nvim]: https://github.com/ggandor/leap.nvim
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
