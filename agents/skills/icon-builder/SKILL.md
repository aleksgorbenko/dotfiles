---
name: icon-builder
description: >
  Use when generating or packaging icons with ~/.dotfiles/bin/gen-icon.sh
  (Pollinations.ai text-to-image) and ~/.dotfiles/bin/pack-icon.sh (iOS/macOS/
  Alfred packaging). Trigger on "generate an icon", "make an icon for X",
  "pack this icon", "alfred workflow icon", "app icon set".
---

# Icon Builder

## Scripts

- `gen-icon.sh "<prompt>" <out.png> [--seed N] [--style "..."]` — single icon, 1024x1024.
- `gen-icon.sh --batch <file.txt> [--outdir DIR] [--seed N] [--style "..."]` — one icon per line, filename slugified from the line text.
- `pack-icon.sh --input <src.png> --output ios|macos|alfred|all [--name NAME]` — converts a 1024x1024 source into the target format(s) under `./out/`.

ALWAYS:
- Reuse the same `--seed` across every icon in a set for visual consistency.
- Visually check the rendered result against the intended prompt after generation — diffusion models frequently distort or substitute embedded text/glyphs (CJK, logos, small labels).
- Re-run with a rephrased/simplified prompt if the render is wrong, rather than accepting a close-enough result.
- Confirm the source PNG is 1024x1024 before `pack-icon.sh` — it warns but still proceeds on a mismatch, degrading quality.
- Use `--output alfred` only for the icon.png + minimal info.plist skeleton it produces — a real workflow's actual info.plist (with its Script Filter nodes etc.) is separate; don't let the packed skeleton overwrite it.

NEVER:
- Trust a diffusion model to render exact text/characters without checking — it's not a font renderer.
- Batch-generate a set where filenames must match a fixed name (e.g. per-keyword icons) — `--batch` slugifies from the line text, which won't match; loop single-mode calls with explicit output paths instead.
- Reuse one icon/character across two distinct items in the same set — pick something distinguishable per item.
