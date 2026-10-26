---
name: brand-assets
description: Make product marketing images (App Store screenshots, website images, Gumroad and LemonSqueezy media, OG image) with brand-assets-kit. Trigger on "make the screenshots", "regenerate marketing images", "update the App Store images", "new website image", "add a scene", "recapture the launcher", "light and dark versions". Not for one-off UI checks (use snapline), copy (use product-copy) or video.
---

# Brand Assets

## Before anything

- Read `~/src/proj/brand-assets-kit/AGENTS.md`; it lists which file answers which question.
- Composition patterns and alignment: kit `README.md` (Composition) and `schema/scenes.schema.json`; no separate alignment skill.

## Steps

1. Pick the scenes to change in `<product>/marketing/scenes.json`; new app window: add it to `views.json` first.
2. Edit layers: background, static components, app views, `anchor` / `offset` / `scale`, `"light": true`.
3. `bun src/cli.ts check <product>/marketing`.
4. App pixels changed (new view, new data, app UI change): `make assets PRODUCT=<abs path> SCENES="id id"`.
5. Layout, caption or background only: `make render PRODUCT=<abs path> SCENES="id id"`.
6. Look at each changed output once at `max_pixel` ~1000; fix config and rerun only that scene.
7. Website: `make sync-assets` in the site repo, then its `make check`.
8. App Store: `asc screenshots upload` only when the user asks.

## Rules

- Never capture views one by one with Snapline or `screencapture`; the kit does it.
- Never ask the user to change a setting, open a window or take a screenshot; the kit sets and restores Reduce Transparency, glass tint and theme.
- Liquid Glass only; dark and light share one background so only the app changes.
- An app view is always captured inside its scene; never paste a lone window capture onto a background.
- The app opens views from its launch variable; never keystrokes or AppleScript.
- Never rerun every scene for a change to one; pass `SCENES`.
- The user must leave the Mac alone during a capture run (~7 s per scene); say so before starting.
- Demo data lives in the product repo; keep each query's results unique to its file.
