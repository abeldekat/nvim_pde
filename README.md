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

I touch type using the right hand
in combination with the forefinger of the left hand

- Leader: `space`
- Main plugins: [akmini.visits_harpooned], [mini.files], [mini.pick], [mini.jump2d] and [leap.nvim]
- Menu: [mini.clue]

### VisitsHarpooned

Internal plugin [akmini.visits_harpooned] is a customized [mini.visits] configuration,
operating in almost the same way as `harpoon`.

- Info in statusline: [akmini.harpoonline]
- Pick visits from all labels: `<leader>j` ("strongest finger")
- Toggle label on visit: `<leader>a`
- The shortcuts normally used for window navigation correspond to visit 1-4 having label:
  `c-j`, `<c-k>`,`<c-l>`,`<c-h>`
- Pick visits from current label: `<leader>ol`
- Switch label: `<leader>oj`
- Add new label: `<leader>oa`
- Maintain visits having label: `<leader>om`
- Clear all visits: `<leader>or`

Pickers can display hints using internal plugin [akmini.pick_hinted]

### Window navigation

- `<c-w>hjkl` (stock `Neovim`)
- `mw`(next window)
- `me`(last accessed window)

### Explorer

- `mk`("rolling fingers"), opening mini.files

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

## Key conflicts

### operators

In my config, the suggested key `gr`("go replace") in [mini.operators] is already used
for the `lsp`("go references").

I prefer "two character hotkeys" as I use some lsp keys quite often(`gd`, `gr`).

Solution: Change operator `gr` into `gs`, mnemonic for "go substitute".

As a consequence, use `gS` instead of suggested key `gs`("go sort") for sort.

### surround

Using [mini.surround]. Suggested keys: `sa sd sr sf sF sh sn`

The "s" is already used by [leap].
Solution: Use the `m` key in combination with `asdf`,
adjacent keys on a qwerty keyboard.
Key `ms` is a mnemonic for `surround substitute`, performing a surround replace.

## Mini

Many of the excellent modules included in [mini.nvim] are used in this config:

`ai`, `align`, `animate`, `base16`, `basics`, `bracketed`,
`clue`, `completion`, `cursorword`, `deps`, `diff`, `extra`,
`files`, `git`, `hipatterns`, `hue`, `icons`, `indentscope`,
`jump2d`, `keymap`, `misc`, `move`, `notify`, `operators`,
`pairs`, `pick`, `snippets`, `splitjoin`, `starter`, `statusline`,
`surround`, `visits`

Relevant discussions:

- [Visits tweaked to operate like `grapple` or `harpoon`](https://github.com/echasnovski/mini.nvim/discussions/1158).
  See internal plugin [ak.mini.visits_harpooned]
- [Augment pickers with labels and hotkeys](https://github.com/echasnovski/mini.nvim/discussions/1109).
  See internal plugin [ak.mini.pick_hinted]
- [Pick bufferlines with treesitter highlighting](https://github.com/echasnovski/mini.nvim/discussions/988).
- [Apply tokyonight dev environment](https://github.com/echasnovski/mini.nvim/discussions/1012).
- [Optimized jumping with jump2d](https://github.com/echasnovski/mini.nvim/discussions/1033).
- [Beta testing mini.deps](https://github.com/echasnovski/mini.nvim/issues/689#issuecomment-1962327624).
- [MiniNotify replacing fidget](https://github.com/echasnovski/mini.nvim/discussions/1602).
- [MiniCompletion using blink fuzzy algorithm](https://github.com/echasnovski/mini.nvim/discussions/1771).

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
- [dotfiles](https://github.com/MariaSolOs/dotfiles/tree/main/.config/nvim) `@mariasolos`

[tmuxp]: https://github.com/tmux-python/tmuxp
[scripts]: https://github.com/abeldekat/scripts
[tmux-sessionizer]: https://github.com/abeldekat/scripts/blob/main/tmux-sessionizer
[leader h]: lua/akshared/color_toggle.lua
[mini.nvim]: https://github.com/echasnovski/mini.nvim
[mini.jump2d]: https://github.com/echasnovski/mini.jump2d
[leap.nvim]: https://github.com/ggandor/leap.nvim
[mini.files]: https://github.com/echasnovski/mini.files
[mini.operators]: https://github.com/echasnovski/mini.operators
[mini.surround]: https://github.com/echasnovski/mini.surround
[mini.pick]: https://github.com/echasnovski/mini.pick
[mini.visits]: https://github.com/echasnovski/mini.visits
[mini.clue]: https://github.com/echasnovski/mini.clue
[akmini.visits_harpooned]: lua/akmini/visits_harpooned.lua
[akmini.harpoonline]: lua/akmini/harpoonline.lua
[akmini.pick_hinted]: lua/akmini/pick_hinted.lua
[peek.nvim]: https://github.com/toppair/peek.nvim
[deno]: https://deno.land
[with_submodules]: https://github.com/abeldekat/nvim_pde/tree/with_submodules
[with_lazynvim]: https://github.com/abeldekat/nvim_pde/tree/with_lazynvim
[tree-sitter]: https://github.com/tree-sitter/tree-sitter
