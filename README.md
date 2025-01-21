# Neovim pde

![1724703495](https://github.com/user-attachments/assets/af8a209d-7707-430e-926c-70f12821adfc)

![1724703946](https://github.com/user-attachments/assets/4fac0567-81fe-48c2-8d79-88b9744803a0)

My _personal development environment_ for Neovim

## Older versions

> [!NOTE]
> Tag [with_submodules] references the version containing `git submodules`,
> `lazy.nvim` and `mini.deps`
>
> Tag [with_lazynvim] references the version containing `lazy.nvim` and `mini.deps`

## Structure

- `init`: Uses `:h vim.loader` and calls `ak.init`
- [ak.init]: Invoke [ak.mini_deps]
- [ak.deps]: Load plugins
- [ak.config]: All setup for plugins, options, key-mappings, auto-commands, and colors
- [ak.mini]: Internal plugins [ak.mini.visits_harpooned] and [ak.mini.pick_hinted]
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

- Leader: `space`
- Main plugins: [ak.mini.visits_harpooned], [oil.nvim], [mini.pick] and [mini.jump2d]
- Menu: [mini.clue]

### VisitsHarpooned

Internal plugin [ak.mini.visits_harpooned] is a customized [mini.visits] configuration,
operating in almost the same way as `harpoon`

- Info in statusline: [ak.mini.visits_harpooned_line]
- The shortcuts normally used for window navigation correspond to visit 1-4 in current label:
  `c-j`, `<c-k>`,`<c-l>`,`<c-h>`
- Toggle current label on visit: `<leader>a`
- Add visit to "uncategorised" label: `<leader>oa`
- Pick visits from all labels: `<leader>j` ("strongest finger")
- Pick visits having current label: `<leader>ol`
- Change current label: `<leader>oj`
- Maintain visits having active label: `<leader>om`
- Remove active label from visits: `<leader>or`
- Copy global visits to "uncategorised" label: `<leader>oc`

Pickers can display hints using internal plugin [ak.mini.pick_hinted]

### Window navigation

- `<c-w>hjkl` (stock `Neovim`)
- `mw`(next window)
- `me`(last accessed window)

### Oil

- `mk`("rolling fingers"), opening oil
- `h` up one level
- `l` down one level, open file

### Tmux

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
  - current buffer has current label (mini.visits)
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

## Key conflicts

Replace **replace** with **substitute** mnemonic:

In my config, the suggested key `gr`("go replace") in [mini.operators] is already used
for the `lsp`("go references").

I prefer "two character hotkeys" as I use some lsp keys quite often(`gd`, `gr`).

Solution: Change operator `gr` into `gs`, mnemonic for "go substitute".

Consequences:

- [mini.operators]: Change suggested key `gs`("go sort") into `gS`.
- [mini.surround]: Change `sr`(surround replace) into `ss`(surround substitute).

The expand key in `mini.snippets` is `<c-j>` by default. That key is already
used to accept completions. I changed the key to `<c-k>`.

## Mini

Many of the excellent modules included in [mini.nvim] are used in this config:

`ai`, `align`, `animate`, `base16`, `clue`, `cursorword`,
`deps`, `diff`, `git`, `hipatterns`, `hue`, `icons`,
`indentscope`, `jump2d`, `move`, `notify`, `operators`, `pairs`,
`pick`, `snippets`, `splitjoin`, `starter`, `statusline`, `surround`,
`visits`

Relevant discussions:

- [From `grapple` to `mini.visits`](https://github.com/echasnovski/mini.nvim/discussions/1158).
  See internal plugin [ak.mini.visits_harpooned]
- [Augment pickers with labels and hotkeys](https://github.com/echasnovski/mini.nvim/discussions/1109).
  See internal plugin [ak.mini.pick_hinted]
- [Pick bufferlines with treesitter highlighting](https://github.com/echasnovski/mini.nvim/discussions/988).
- [Apply tokyonight dev environment](https://github.com/echasnovski/mini.nvim/discussions/1012).
- [Optimized jumping with jump2d](https://github.com/echasnovski/mini.nvim/discussions/1033).
- [Beta testing mini.deps](https://github.com/echasnovski/mini.nvim/issues/689#issuecomment-1962327624).

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
[ak.mini]: lua/ak/mini
[ak.util]: lua/ak/util
[leader h]: lua/ak/util/color.lua
[mini.nvim]: https://github.com/echasnovski/mini.nvim
[mini.operators]: https://github.com/echasnovski/mini.operators
[mini.surround]: https://github.com/echasnovski/mini.surround
[mini.pick]: https://github.com/echasnovski/mini.pick
[mini.visits]: https://github.com/echasnovski/mini.visits
[mini.jump2d]: https://github.com/echasnovski/mini.jum2d
[mini.clue]: https://github.com/echasnovski/mini.clue
[ak.mini.visits_harpooned]: lua/ak/mini/visits_harpooned.lua
[ak.mini.visits_harpooned_line]: lua/ak/mini/visits_harpooned_line.lua
[ak.mini.pick_hinted]: lua/ak/mini/pick_hinted.lua
[oil.nvim]: https://github.com/stevearc/oil.nvim
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
