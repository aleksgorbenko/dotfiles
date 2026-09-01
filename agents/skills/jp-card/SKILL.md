---
name: jp-card
description: >
  Create Japanese learning flashcards as Obsidian Markdown notes from a word, grammar
  pattern, or sentence. Trigger when the user wants to make a Japanese card/note/flashcard,
  add a grammar point, add vocab, or break down a sentence — phrases like "jp card",
  "make a grammar note", "add Japanese word", "flashcard for ～ても", "/jp-card". Handles
  three card types: grammar, word, sentence.
---

# Japanese Card Skill

Create ONE Obsidian Markdown note per invocation from a Japanese word, grammar pattern, or sentence.

## Args

`/jp-card <type> <input>` where type ∈ `grammar | word | sentence`.

If type omitted, infer: multi-word Japanese with punctuation → `sentence`; single lexical word → `word`; particle/pattern/conjugation → `grammar`. If ambiguous, ask.

## Steps

1. Read the matching template — never inline it here (single source of truth):
   `/Users/gbko/Library/Mobile Documents/iCloud~md~obsidian/Documents/mosk/_template/new_japanese_{type}.md`
2. Fill EVERY `{placeholder}`. No leftover braces.
3. Generate values per shared + per-type rules below.
4. Write file to vault notes dir (same folder the user specifies, else ask once and remember).
5. Run validation gate before finishing.

## Shared rules

- `id`: full UUID v4 (generate real one, e.g. `uuidgen`).
- `created_at`: today, `yyyy-mm-dd`.
- `JLPT`: real level `N5`–`N1`. Always set.
- `sequence`: integer, one global ordering per card type (grammar cards share one sequence, sentence cards share their own). Determines study order — NOT tied to JLPT level or file location. Check `LEARNING_PATH.md` for the next free number in the right stage; insert the new card's stage-order position and shift-renumber only if truly needed (prefer decimals like `12.5` over a mass renumber when inserting between two adjacent existing numbers). A sentence card takes the `sequence` of the grammar point it targets (not a fresh number) — reuse is fine, multiple sentence cards can share one grammar's number.
- `status`: emoji review-state field. `🔴` new/unreviewed (default for every new card) → `🟠` reviewing/shaky → `🟢` confident. Set new cards to `🔴`. Never infer or upgrade this yourself — only the user changes it as they review. Place FIRST in frontmatter, above `id` — fastest field to reach and edit via keyboard.
- `{level}` tag: lowercase JLPT, e.g. `n5`.
- Write Japanese in normal orthography — use kanji where a word is normally written in kanji (食べる, 本, 読む, 公園, 私), with kana only where natural (grammatical particles, okurigana, given names usually in kana, words normally kana). Never render a whole sentence in all-hiragana.
- Follow the template's blank lines exactly. NEVER put a paragraph line directly above `---` — Obsidian renders that text as a setext heading. Always keep a blank line before any `---` that follows prose (e.g. before `##### Links`).
- Backtick Japanese grammar/lexical elements — EXCEPT translation lines and breakdown sections (leave those plain).
- English explanations, concise.
- Never invent grammar names or fake "forms".
- **Links** (grammar template only): search CureDolly `https://kellenok.github.io/cure-script/` and Yoku `https://yoku.bi/Introduction.html` for a page explaining this exact or closely-related point. Use WebFetch to VERIFY the URL resolves (not 404) before adding. If none, write `n/a`. Never guess URLs.

## type: grammar

**Type field** — exactly one of:
`Particle` · `Auxiliary verb` · `Verb conjugation` · `Clause connector` · `Sentence pattern` · `Noun construction` · `Adjective construction` · `Particle + verb construction`

Never use `Grammar`, `Grammar pattern`, or invent labels. Pick by grammatical *function*.

**Multi-part separation** — if the construction is multiple pieces, show them separate, never fused. Backtick each piece. Correct: Verb(~て) + も as two constructions. Wrong: fusing into one ~ても "form".

**Follows** — list attachment per category separately, never merge even if identical surface form. Backtick the Japanese pieces. Use Japanese grammatical categories, not vague English (thing/place/object). Check each that applies: Verb, い-adjective, な-adjective, Noun — e.g. Verb(~て) + も, い-adjective(~くて) + も, な-adjective + でも, Noun + でも. Show the final learner-facing attachment, not intermediate conjugation steps.

Layout: put the attachment RULE on its own bullet, and each concrete example/derivation on its own indented sub-bullet (2 spaces). One example per line — never cram multiple derivations onto one line with `;` or after a `—`. Human-readable, not machine-dense. Example:
```
- Godan Verb(あ-stem) + `せる`
  - `のむ` → `のま` + `せる` = `のませる`
- Ichidan Verb(minus `る`) + `させる`
  - `たべる` → `たべ` + `させる` = `たべさせる`
```

**Examples** — one per applicable Follows category, each demonstrating exactly one attachment. Label the category. Backtick the grammar pattern inside every example. Don't combine two target attachments in one sentence. Don't end example with 。. For な-adjective examples pick words unambiguously な-adjectives.

**Breakdown** — explain each component in ITS role in THIS construction, not a borrowed meaning. Correct: ~て = て-form used before も. Wrong: ~て = and/connection form. (Plain text, no backticks here.)

**Note** — the `{note}` line is OPTIONAL. Fold conjugation forms, usage restrictions, and contrasts into the meaning paragraph instead. Only add a note for a fact NOT derivable from meaning/Follows/examples. Never restate them. If nothing new, drop the note line entirely (keep the separator + Links).

## type: word

- `{word}`, `{translation}`.
- `Type`: linguistic type(s) — noun, ichidan verb, godan verb, い-adjective, な-adjective, adverb, etc. Multiple allowed.
- Two natural example sentences using the word. Backtick the target word inside each; rest plain.

## type: sentence

- `{sentence}`, `{translation}`.
- Breakdown: one line per word/particle/pattern, `element - meaning/role` (element plain, no backticks). Cover every meaningful token.

## Validation gate

1. No leftover `{placeholder}` or braces.
2. Japanese backticked except translation + breakdown lines (those plain).
3. (grammar) Multi-part constructions separated, not fused.
4. (grammar) Follows categories separated correctly, none merged.
5. (grammar) No conjugation step described as the grammar rule.
6. (grammar) `Type` is a linguistic category from the enum, not "Grammar".
7. (grammar) Every link WebFetch-verified live, else `n/a`.
8. Valid UUID, today's date, JLPT set.
9. `sequence` set, matches its stage position in `LEARNING_PATH.md` (grammar) or its target grammar's number (sentence).
