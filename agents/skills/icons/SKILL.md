---
name: icons
description: >
  Use when making, fetching or packaging any icon: SF Symbol or emoji icons,
  open-source icon sets (Iconify: Lucide, Material, Tabler, brand logos),
  website favicons, installed app icons by bundle ID, macOS menu-bar template
  images, iOS/macOS/Alfred icon packaging, renaming exported icon files, or a
  product's app icon (Icon Composer `.icon`, every size). Trigger on "make an icon",
  "icon for X", "Alfred workflow icon", "result icons", "app icon", "favicon",
  "menu bar icon", "pack this icon", "SF Symbol".
---

# Icons

Every icon job is one action of `brand icon <action>` (`~/.dotfiles/bin/brand`, runs brand-assets-kit's `src/cli.ts`; `BRAND_ASSETS_KIT` overrides the kit path). Each action prints the written paths and exits non-zero on failure.

## Pick an action

| Need | Action |
|---|---|
| A product's app icon: `.icon` into Xcode, `.icns`, every PNG size, appearance previews, web icons | `app` (or `make app-icon` in the kit) |
| Simple glyph (Alfred, menus, toolbars) | `symbol` |
| Emoji | `emoji` |
| Glyph SF Symbols lacks, or a brand logo | `iconify` |
| A website's own icon | `favicon` |
| An installed app's icon | `extract` |
| Any existing PNG/SVG/ICNS on a background | `compose` |
| Restyle an existing full-bleed logo icon to the macOS grid | `polish` |
| Menu-bar template image set | `menubar` |
| iOS / macOS `.icns` / Alfred bundle | `pack` |
| Rename exported `<prefix>*@1x.png` files | `rename` |

## Actions

- `app <marketing folder>` - reads `marketing/app-icon.json` (glyph SVG, Xcode `AppIcon.icon` path); house style: black fill, flat glyph.
- `symbol <symbol> <out.png>` / `--batch <file> [--outdir DIR]` - SF Symbol on a rounded square; defaults `--bg #FF0033 --fg #1C1C1E --weight semibold --size 1024`.
- `emoji "<emoji>" <out.png>` / `--batch` - Apple Color Emoji; default `--bg #FF0033`.
- `iconify <set:name> <out.png>` / `--batch` / `--search <query> [--set lucide,tabler] [--limit N]` - Iconify API; `--fg original` keeps multicolour logos.
- `favicon <domain> <out.png>` - tries `apple-touch-icon.png`, Google s2, DuckDuckGo; keeps the largest; default `--size 256 --bg none`.
- `extract [--size N] <out-dir|*.xcassets> <bundle-id>...` - the icon macOS shows for the installed app (works for `.icon`-only apps); writes `<bundle-id>_<N>x<N>.png` or `<bundle-id>.imageset/icon.png`.
- `compose <in> <out.png>` / `--text "<emoji>"` - shared engine: trims transparent edges, centres, optional rounded background.
- `polish <in.png> <out.png> [--whole] [--bg #RRGGBB]` - lifts the logo off its sampled background and redraws it with `--style macos`; `--whole` fits an icon with its own shape (e.g. stacked) to the grid unchanged.
- `menubar <glyph.png> <out.imageset> [height]` - black-on-white glyph to 1x/2x/3x template set.
- `pack --input <1024.png> --output ios|macos|alfred|all [--name NAME] [--outdir DIR]` - default `./out/`.
- `rename <prefix> [dir]` - `<prefix>X@1x.png` to `icon_X.png`, never overwrites.
- `sfsymbols search <term>` - find SF Symbol names (dotfiles wrapper, not part of `brand`).

Shared options on every renderer: `--size N`, `--bg #RRGGBB|none`, `--radius F` (0.2237), `--inset F` (0), `--glyph F` (0.56 with a background, 1.0 without), `--style flat|macos` (flat).

`--style macos`: 824/1024 grid squircle, top-lit gradient from `--bg`, glyph shadow, rim highlight, drop shadow - matches app icons in Alfred and the Dock.

Batch files hold one `<name> <source> [#RRGGBB]` line per icon; the colour column overrides `--bg`; `#` lines and blank lines are skipped.

`icon-symbol.sh` and `icon-polish.sh` stay in `~/.dotfiles/bin` as one-line shims for Alfred Makefiles; new code calls `brand icon`.

## ALWAYS

- Render every Alfred workflow icon (`icon.png`) with `--style macos` (or `polish` for a brand logo) at 1024px, so all workflows share the app-icon grid and corner shape.
- Check names before rendering: `sfsymbols search <term>` for SF Symbols, `brand icon iconify --search <query> --set <sets>` for Iconify.
- Keep one `--fg`/`--weight` across every icon in a set; vary the background only to group related items (e.g. one colour per section), via the batch file's colour column.
- Keep a repo's icon list in a batch file (e.g. `tools/icons.txt`) behind a `make icons` target, so icons rebuild with one command.
- Look at rendered icons (contact sheet or Read) before shipping - check centring and that each item is distinguishable.
- Feed `pack` a 1024x1024 source.
- Run `make check` in brand-assets-kit after editing `src/icons.ts`, `src/icon-cli.ts` or `tools/*.swift`.

## NEVER

- Reuse one glyph for two distinct items in the same set.
- Upscale a small favicon for a large icon without checking the `warning: upscaling` line; prefer `iconify` with `simple-icons:` or `logos:` for brands.
- Let `pack --output alfred`'s skeleton `info.plist` overwrite a real workflow's `info.plist`.
- Use emoji or Iconify icons inside a menu-bar template set without `menubar` - multicolour art is not template material.
- Call the SF Symbols binary through a symlink - it cannot find its resources; use the `sfsymbols` wrapper or the full app path.
- Use an SF Symbol directly as an app icon; draw a glyph SVG in the house style and run `app`.
