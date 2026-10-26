---
name: product-copy
description: Write or review marketing copy for an app in Apple's style - website sections, hero lines, feature blurbs, FAQ answers, App Store name, subtitle, promotional text, description and keywords. Trigger on "write the copy", "reword this section", "App Store description", "subtitle", "tagline", "FAQ answer", "is this copy good". Not for release notes (use asc-whats-new-writer) or docs.
---

# Product Copy

## Process

1. Use copy the user dictates verbatim; fix only typos; raise factual problems separately, never rewrite their wording.
2. Check every claim against the code, data or a measurement before writing it; no claim you cannot point to.
3. Give each section one job; never repeat a fact in the next section.
4. Show drafts as plain text for approval before they go on a page.
5. Run the repo's spelling and prose linters (cspell en-GB, Vale) when it has them.

## Voice

- Lead with what the user can do, then how.
- Short sentences, one idea each; second person; active voice; present tense.
- Plain verbs: open, find, switch, close, copy.
- Concrete nouns: tabs, bookmarks, history, not "content" or "data".
- No superlatives, no "simply", "just", "seamless", "powerful", "blazing".
- Numbers only when measured on the current build.
- No exclamation marks or emoji.
- British English; plain hyphen, never an em dash.

## Apple names

- Never use an Apple product name as a style for your product ("Spotlight-style", "Siri-like").
- No plural or possessive Apple trademarks: "Mac computers", not "Macs"; never "the Mac's".
- Write "Apple silicon", "macOS", "Mac App Store", "App Store", "Shortcuts".
- No wording that implies Apple endorsement.

## Mac terms

- "keyboard shortcut", not "hotkey"; "Settings", not "Preferences"; "click", not "tap".
- Keys: Command ⌘, Option ⌥, Shift ⇧, Control ⌃, Return ↩, Delete ⌫, Escape ⎋.
- "menu bar", "Dock", "window", "full-screen".

## Surfaces

| Surface | Shape | Limit |
|---|---|---|
| App Store name | Product name, optional short descriptor | 30 characters |
| App Store subtitle | One benefit phrase | 30 characters |
| Promotional text | What is new or timely | 170 characters |
| Description | First line is the main benefit; short paragraphs; feature list | 4000 characters |
| Keywords | Comma-separated, no spaces, no app name or category | 100 characters |
| Website hero tagline | What it is, one line | - |
| Website section | 2-4 word title, one-sentence summary, optional list | - |
| FAQ | Question in the user's words; answer's first sentence answers it | - |
| Screenshot caption | One benefit, under 8 words | - |
