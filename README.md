# Neovim pde

![1724703495](https://github.com/user-attachments/assets/af8a209d-7707-430e-926c-70f12821adfc)

![1724703946](https://github.com/user-attachments/assets/4fac0567-81fe-48c2-8d79-88b9744803a0)

My Neovim config, based on [MiniMax]

> [!NOTE]
> Tag [with_submodules] references the version containing `git submodules`,
> `lazy.nvim` and `mini.deps`
>
> Tag [with_lazynvim] references the version containing `lazy.nvim` and `mini.deps`
>
> Tag [without_minimax] references the version before switching to `minimax`

## Install

> Requirements: Neovim latest version or nightly. See [MiniMax requirements]
>
> Always review the code before trying a configuration.

Clone the repository:

```sh
git clone https://github.com/abeldekat/nvim_pde ~/.config/ak
```

Open Neovim and install the plugins:

```sh
NVIM_APPNAME=ak nvim
```

Remove the config:

```sh
rm -rf ~/.local/share/ak ~/.local/state/ak ~/.cache/ak
rm -rf ~/.config/ak
```

## Structure

See [MiniMax]. However, in case the `setup` of a plugin is customized,
the corresponding code will be contained in a dedicated lua module.

## Workflow

- Leader: `space`
- Main plugins: [mini.visits], [mini.files], [mini.pick], [mini.jump2d]
- Menu: [mini.clue]
- Keyboard: Halcyon Ferris, a split keyboard with 34 keys

### FilesClued

MiniClue shows bookmarks and relevant `g` mappings from MiniFiles using internal module [akextra.files_clued]

### FilesLayout

Layouts and a full-screen toggle for [mini.files] using internal module [akextra.files_layout]

### PickHinted

Pickers from [mini.pick] can display hints using internal module [akextra.pick_hinted]

### Kitty

- Custom [kitty-sessionizer]
- Kitty sessions at the top of the screen
- Most mappings use tmux bindings: `ctrl space`
- navigation:
  - `kitty-sessionizer`: leader h
  - existing sessions: leader k
  - alternate session: leader j
  - alternate tab: leader l
  - switch window: leader o

## UI

- `mini.statusline`, no colors, except on:
  - mode other than normal
  - macro recording
  - tab-page is not the first
- many color schemes

Change color schemes:

- on each startup, see [scripts], `vim_menu_owns`
- mini.pick, `leader f T`
- change the variant of the current theme using [leader o c]

Script `vim_menu_owns` writes to `lua.ak.colors`.
Ignoring changes to that file:

```sh
git update-index --assume-unchanged lua/ak/colors.lua
```

## Mini

Relevant discussions:

- [MiniClue: Show bookmarks and `g` mappings from MiniFiles](https://github.com/nvim-mini/mini.nvim/discussions/2519)
- [Traverse styles in mini.files](https://github.com/nvim-mini/mini.nvim/discussions/2448)
- [MiniNotify replacing fidget](https://github.com/nvim-mini/mini.nvim/discussions/1602).
- [Augment pickers with labels and hotkeys](https://github.com/nvim-mini/mini.nvim/discussions/1109).
- [Optimized jumping with jump2d](https://github.com/nvim-mini/mini.nvim/discussions/1033).

## Environment

[arch linux](https://archlinux.org/)
[awesome](https://github.com/abeldekat/awesome)
[kitty](https://github.com/abeldekat/kitty)
[zsh](https://github.com/abeldekat/zsh)
[scripts](https://github.com/abeldekat/scripts)

## Acknowledgements

This config is based on [MiniMax].
Additionally, code and ideas have been used from the following sources:

- [nvim](https://github.com/echasnovski/nvim) `@echasnovski`
- [nvim](https://github.com/pkazmier/nvim) `@pkazmier`
- [mini.nvim discussions](https://github.com/nvim-mini/mini.nvim/discussions)

[scripts]: https://github.com/abeldekat/scripts
[kitty-sessionizer]: https://github.com/abeldekat/scripts/blob/main/kitty_sessionizer_owns
[leader o c]: plugin/29_colors.lua
[MiniMax]: https://github.com/nvim-mini/MiniMax
[MiniMax requirements]: https://github.com/nvim-mini/MiniMax?tab=readme-ov-file#software
[mini.files]: https://github.com/nvim-mini/mini.files
[mini.jump2d]: https://github.com/nvim-mini/mini.jump2d
[mini.pick]: https://github.com/nvim-mini/mini.pick
[mini.visits]: https://github.com/nvim-mini/mini.visits
[mini.clue]: https://github.com/nvim-mini/mini.clue
[akextra.files_clued]: lua/akextra/files_clued.lua
[akextra.files_layout]: lua/akextra/files_layout.lua
[akextra.pick_hinted]: lua/akextra/pick_hinted.lua
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
[without_minimax]: https://github.com/abeldekat/nvim_pde/tree/without_minimax
