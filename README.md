# Neovim pde

![1724703495](https://github.com/user-attachments/assets/af8a209d-7707-430e-926c-70f12821adfc)

![1724703946](https://github.com/user-attachments/assets/4fac0567-81fe-48c2-8d79-88b9744803a0)

My _personal development environment_ for Neovim based on [MiniMax]

> [!NOTE]
> Tag [with_submodules] references the version containing `git submodules`,
> `lazy.nvim` and `mini.deps`
>
> Tag [with_lazynvim] references the version containing `lazy.nvim` and `mini.deps`
>
> Tag [without_minimax] references the version before switching to `minimax`

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

Notes: For [peek.nvim], [deno] needs to be installed. For [tree-sitter], the CLI must be installed.

## Workflow

- Leader: `space`
- Main plugins: [akextra.visits_harpooned], [mini.files], [mini.pick], [mini.jump2d]
- Menu: [mini.clue]
- Keyboard: Halcyon Ferris, a split keyboard with 34 keys

### VisitsHarpooned

Internal plugin [akextra.visits_harpooned] is a customized [mini.visits] configuration,
operating in almost the same way as `harpoon`.

TODO: The shortcuts changed...

Pickers can display hints using internal plugin [akextra.pick_hinted]

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
- many color schemes

Change color schemes:

- on each startup, see [scripts], `vim_menu_owns`
- mini.pick, `leader f o c`, loads all colors, does not show builtin color schemes
- change the palette of the current color scheme using [leader h]

Script `vim_menu_owns` writes to `lua.ak.colors`.
Ignoring changes to that file:

```sh
git update-index --assume-unchanged lua/ak/colors.lua
```

## Mini

Relevant discussions:

- [Visits tweaked to operate like `grapple` or `harpoon`](https://github.com/nvim-mini/mini.nvim/discussions/1158).
  See internal plugin [akextra.visits_harpooned]
- [Augment pickers with labels and hotkeys](https://github.com/nvim-mini/mini.nvim/discussions/1109).
  See internal plugin [akextra.pick_hinted]
- [Pick bufferlines with treesitter highlighting](https://github.com/nvim-mini/mini.nvim/discussions/988).
- [Apply tokyonight dev environment](https://github.com/nvim-mini/mini.nvim/discussions/1012).
- [Optimized jumping with jump2d](https://github.com/nvim-mini/mini.nvim/discussions/1033).
- [Beta testing mini.deps](https://github.com/nvim-mini/mini.nvim/issues/689#issuecomment-1962327624).
- [MiniNotify replacing fidget](https://github.com/nvim-mini/mini.nvim/discussions/1602).
- [MiniCompletion using blink fuzzy algorithm](https://github.com/nvim-mini/mini.nvim/discussions/1771).
- [Jump with second character from each spot](https://github.com/nvim-mini/mini.nvim/discussions/1860)

## Environment

[tmux](https://github.com/abeldekat/tmux)
[alacritty](https://github.com/abeldekat/alacritty)
[zsh](https://github.com/abeldekat/zsh)
[scripts](https://github.com/abeldekat/scripts)
[awesome](https://github.com/abeldekat/awesome)
[arch linux](https://archlinux.org/)

## Acknowledgements

This config is based on [MiniMax].
Also, code and ideas have been used from the following repositories:

- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [mini.deps](https://github.com/nvim-mini/mini.deps)
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)

[tmuxp]: https://github.com/tmux-python/tmuxp
[scripts]: https://github.com/abeldekat/scripts
[tmux-sessionizer]: https://github.com/abeldekat/scripts/blob/main/tmux-sessionizer
[leader h]: lua/akshared/color_toggle.lua
[MiniMax]: https://github.com/nvim-mini/MiniMax
[mini.files]: https://github.com/nvim-mini/mini.files
[mini.jump2d]: https://github.com/nvim-mini/mini.jump2d
[mini.pick]: https://github.com/nvim-mini/mini.pick
[mini.visits]: https://github.com/nvim-mini/mini.visits
[mini.clue]: https://github.com/nvim-mini/mini.clue
[akextra.pick_hinted]: lua/akextra/pick_hinted.lua
[akextra.visits_harpooned]: lua/akextra/visits_harpooned.lua
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
[without_minimax]: https://github.com/abeldekat/nvim_pde/tree/without_minimax
[tree-sitter]: https://github.com/tree-sitter/tree-sitter
