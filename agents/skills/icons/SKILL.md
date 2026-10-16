---
name: icons
description: >
  Use when making, fetching or packaging any icon: SF Symbol or emoji icons,
  open-source icon sets (Iconify: Lucide, Material, Tabler, brand logos),
  website favicons, installed app icons by bundle ID, macOS menu-bar template
  images, iOS/macOS/Alfred icon packaging, or renaming exported icon files.
  Trigger on "make an icon", "icon for X", "Alfred workflow icon", "result icons",
  "app icon", "favicon", "menu bar icon", "pack this icon", "SF Symbol".
---

# Icons

All scripts live in `~/.dotfiles/bin`, share the `icon-<job>.sh` naming, print the written path, and exit non-zero on failure.

## Pick a source

| Need | Script |
|---|---|
| Simple glyph (Alfred, menus, toolbars) | `icon-symbol.sh` |
| Emoji | `icon-emoji.sh` |
| Glyph SF Symbols lacks, or a brand logo | `icon-iconify.sh` |
| A website's own icon | `icon-favicon.sh` |
| An installed app's icon | `icon-app.sh` |
| Any existing PNG/SVG/ICNS on a background | `icon-compose.sh` |
| Menu-bar template image set | `icon-menubar.sh` |
| iOS / macOS `.icns` / Alfred bundle | `icon-pack.sh` |
| Rename exported `<prefix>*@1x.png` files | `icon-rename.sh` |

## Scripts

- `icon-symbol.sh <symbol> <out.png>` / `--batch <file> [--outdir DIR]` - SF Symbol on a rounded square; defaults `--bg #FF0033 --fg #1C1C1E --weight semibold --size 1024`.
- `icon-emoji.sh "<emoji>" <out.png>` / `--batch` - Apple Color Emoji; default `--bg #FF0033`.
- `icon-iconify.sh <set:name> <out.png>` / `--batch` / `--search <query> [--set lucide,tabler] [--limit N]` - Iconify API; `--fg original` keeps multicolour logos.
- `icon-favicon.sh <domain> <out.png>` - tries `apple-touch-icon.png`, Google s2, DuckDuckGo; keeps the largest; default `--size 256 --bg none`.
- `icon-app.sh [--size N] <out-dir|*.xcassets> <bundle-id>...` - extracts from the installed app's `.icns`.
- `icon-compose.sh <in> <out.png>` / `--text "<emoji>"` - shared engine: trims transparent edges, centres, optional rounded background.
- `icon-menubar.sh <glyph.png> <out.imageset> [height]` - black-on-white glyph to 1x/2x/3x template set.
- `icon-pack.sh --input <1024.png> --output ios|macos|alfred|all [--name NAME]` - writes into `./out/`.
- `icon-rename.sh <prefix> [dir]` - `<prefix>X@1x.png` to `icon_X.png`, never overwrites.
- `sfsymbols search <term>` - find SF Symbol names.

Shared options on every renderer: `--size N`, `--bg #RRGGBB|none`, `--radius F` (0.2237), `--inset F` (0), `--glyph F` (0.56 with a background, 1.0 without).

Batch files hold one `<name> <source>` pair per line; `#` lines and blank lines are skipped.

## ALWAYS

- Check names before rendering: `sfsymbols search <term>` for SF Symbols, `icon-iconify.sh --search <query> --set <sets>` for Iconify.
- Keep one `--bg`/`--fg`/`--weight` across every icon in a set.
- Keep a repo's icon list in a batch file (e.g. `tools/icons.txt`) behind a `make icons` target, so icons rebuild with one command.
- Look at rendered icons (contact sheet or Read) before shipping - check centring and that each item is distinguishable.
- Feed `icon-pack.sh` a 1024x1024 source; it warns but still runs on other sizes.
- Run `~/.dotfiles/lib/icons/test.sh` after editing any icon script or `lib/icons/*.swift`.

## NEVER

- Reuse one glyph for two distinct items in the same set.
- Upscale a small favicon for a large icon without checking the `warning: upscaling` line; prefer `icon-iconify.sh` with `simple-icons:` or `logos:` for brands.
- Let `icon-pack.sh --output alfred`'s skeleton `info.plist` overwrite a real workflow's `info.plist`.
- Use emoji or Iconify icons inside a menu-bar template set without `icon-menubar.sh` - multicolour art is not template material.
- Call the SF Symbols binary through a symlink - it cannot find its resources; use the `sfsymbols` wrapper or the full app path.
