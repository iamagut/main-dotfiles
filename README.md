# main-dotfiles

A Hyprland dotfile collection mostly cobbled together from [ml4w](https://github.com/mlademi2/ml4w) and [HyDE](https://github.com/HyDE-Projects/HyDE), styled on a [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) base with [matugen](https://github.com/Baroban/matugen) doing the dynamic coloring.

> ⚠️ This is a personal rig, not a polished, production-ready config. Take it as a starting point or a reference for *ideas* — tweak the pieces you like and don't take it too literally.

## Layout

```text
.
├── README.md
└── .config/
    ├── hypr/         # Hyprland config (keybindings, layouts, animations, misc)
    ├── waybar/       # status bar
    ├── swaync/       # notification daemon
    ├── wlogout/      # lock-screen / wm glyph picker
    ├── rofi/         # launcher & window picker
    ├── quickshell/   # quick-app switcher
    ├── kitty/        # terminal config & keybindings
    ├── fish/         # shell functions/config
    ├── nvim/         # Neovim config
    ├── starship/     # prompt theming (starship.toml)
    ├── matugen/      # matugen config (dynamic color generation)
    ├── fontconfig/   # font smoothing / scaling
    ├── Kvantum/      # Kvantum icon/theme
    ├── QtProject/    # Qt app metadata
    ├── qt5ct/        # Qt5 styling & decorations
    ├── qt6ct/        # Qt6 styling & decorations
    ├── gtk-3.0/      # GTK 3 theming
    ├── gtk-4.0/      # GTK 4 theming
    ├── spicetify/    # Spotify theming (spicetify + theme/plugins)
    ├── btop/         # terminal file manager / monitor stats
    ├── cava/         # audio visualizer config
    └── fastfetch/    # boot logo & system info printout
└── .local/
    ├── bin/          # custom scripts (e.g. wallpaper picker)
    ├── chrome/       # pywalfox "chrome" theme folder
    └── share/        # shared data
```

## Setup (rough sketch)

> Most of this is "install the apps, drop the configs, adjust to taste."

1. Copy the relevant `.config/*` and `.local/*` dirs/files into your own `~/.config` and `~/.local` (respecting your XDG paths).
2. Install fonts, themes, and QT/Kvantum resources (e.g. Catppuccin Mocha).
3. Install the referenced apps (Hyprland, waybar, SwayNC, rofi/quickshell, kitty, nvim, btop, cava, fastfetch, pywalfox, spicetify, …).
4. **matugen is dynamic**: it regenerates your GTK/Qt/Kvantum theme files from whatever wallpaper is on screen, so set a wallpaper and re-run `matugen` whenever you want a matching palette. Some of my theme files are scuffed — re-running matugen is the easiest fix.

## The special apps

A few extras that aren't standard dotfiles but are worth calling out because they're fiddly to set up.

<details>
<summary>⚠️ <strong>Vivaldi</strong></summary>

Enable the Vivaldi CSS thing and point it at `~/.local/share/vivaldiCSS`.

</details>

<details>
<summary>⚠️ <strong>Firefox</strong></summary>

- Go to `about:support`, search for `toolkit.legacyUserProfileCustomizations.stylesheets`, and set it to `true`. Then drop the `chrome/` folder from here into your Firefox profile directory.
- For dynamic theming, run `pipx install pywalfox` and then `pywalfox install` to grab the extension, and let it apply matching styles.

</details>

## Wallpapers

matugen needs a wallpaper to color from, so here's the usual suspects:

- [HyDE Gallery](https://github.com/Hyde-project/hyde-gallery) — my personal favorite
- [dharmx/walls](https://github.com/dharmx/walls)
- [D3Ext/aesthetic-wallpapers](https://github.com/D3Ext/aesthetic-wallpapers)

### Helper script

- `.local/bin/wallpaper-picker.sh` — my small script for picking a wallpaper.

## Epic Stuff

- **[HyDE](https://github.com/HyDE-Projects/HyDE)** — honestly the best Hyprland experience I've had while learning; the base of everything here.
- **[ml4w](https://github.com/mlademi2/ml4w)** — foundational reference.
- **[matugen](https://github.com/Baroban/matugen)** — for the dynamic coloring.
