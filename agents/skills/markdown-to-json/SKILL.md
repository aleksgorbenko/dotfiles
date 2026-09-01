---
name: markdown-to-json
description: Use when asked to parse markdown into JSON/structured data, extract headings/lists/tables/paragraphs from markdown programmatically, or build a markdown scraper/parser in Python. Not for rendering markdown to HTML (call MarkdownIt().render() directly) and not for a one-off known-fixed-format extraction where a couple of string.split() calls are simpler.
---

# markdown-to-json

Use markdown-it-py's `SyntaxTreeNode`, never hand-roll token-stream walking (manually tracking open/close depth) or regex-match markdown syntax directly. A flat non-recursive token walk misses nested formatting (bold-inside-italic-inside-link); `SyntaxTreeNode` handles it for free.

## Setup

```python
from markdown_it import MarkdownIt
from markdown_it.tree import SyntaxTreeNode

md = MarkdownIt("gfm-like").disable(["linkify"])
node = SyntaxTreeNode(md.parse(text))
```

- `"gfm-like"` = GFM tables + `~~double-tilde~~` strikethrough. Table support is core, no extra package needed.
- Don't use `"gfm-like2"` if the content uses bare `~` for anything else (grammar notation, ranges, etc.) — it adds single-tilde strikethrough (`~text~`) and will silently eat that content.
- `linkify` needs `linkify-it-py` installed; disable it unless that package is actually present, or `.enable("table")` on `"commonmark"`/`"zero"` raises.
- `.enable("table")` on `"commonmark"`/`"zero"` gets tables alone, without strikethrough/linkify — simpler when GFM's other extensions aren't wanted.

## Inline text extraction

Do **not** use `Renderer.renderInlineAsText()` — its own docstring says "Don't try to use it!" (a CommonMark image-alt-text kludge), and it's missing `hardbreak`/`code_inline` handling. Write this instead:

```python
def plain_text(n) -> str:
    if n.type == "text":
        return n.content
    if n.type == "code_inline":
        return n.content
    if n.type in ("softbreak", "hardbreak"):
        return "\n"
    if n.children:
        return "".join(plain_text(c) for c in n.children)
    return ""
```

Recurses through `strong`/`em`/`link`/`s` wrapper nodes automatically.

## Block types -> JSON shape

| Node type | Shape |
|---|---|
| `heading` | `{"type": "heading", "level": int(n.tag[1]), "text": plain_text(n.children[0])}` |
| `paragraph` | `{"type": "paragraph", "text": plain_text(n.children[0])}` |
| `bullet_list` / `ordered_list` | `{"type": "list", "ordered": n.type == "ordered_list", "items": [walk(li) for li in n.children]}` |
| `list_item` | own text (usually a `paragraph` child) + any nested `bullet_list`/`ordered_list` sibling child, both under the same `list_item` — `{"text": ..., "children": [walk(c) for c in n.children]}` |
| `table` | header from `thead.children[0]` (a `tr`), rows from `tbody.children` (each a `tr`) — `{"type": "table", "header": [...], "rows": [[...], ...]}` |
| `fence` / `code_block` | `{"type": "code", "lang": n.info or None, "text": n.content}` — raw `.content`, not inline-tokenized |
| `blockquote` | `{"type": "blockquote", "children": [walk(c) for c in n.children]}` |

## Pitfalls

- `th`/`td` node `.content` is always empty — text lives in its `inline` child (`n.children[0]`), even for a single plain word.
- `heading.tag` is `"h1"`.."h6"`; level is `int(tag[1])`, no separate level attribute.
- A stray heading anywhere in the document (an LLM aside like "# Thank You!" mid-file) parses as a real `heading` node like any other. To find one canonical "section level" across a document, count occurrences per level and pick the shallowest level with enough occurrences (e.g. >=3) — don't assume the first heading's level is it.
- `SyntaxTreeNode` supports `len()`/indexing/iteration like a list, but leaf nodes (`text`, `code_inline`) have `children = None` — check `.type` before assuming children exist.
- Table-cell alignment (from `:---:`-style separators) lives in `attrs["style"]` on the `th`/`td` node (e.g. `"text-align:center"`), not on the `inline` child.
