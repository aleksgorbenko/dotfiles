#!/usr/bin/env python3
import argparse
import importlib.util
import json
import pathlib
import re
import sys
import tomllib

DESCRIPTION_LIMIT = 4000
PROMOTIONAL_TEXT_LIMIT = 170
KEYS = re.compile(r"\[\[(?!sf:)([^\]]+)\]\]")
SYMBOL = re.compile(r"\[\[sf:[^\]]+\]\]\s*")
LEADING_KEYS = re.compile(r"^((?:\[\[(?!sf:)[^\]]+\]\]\s*)+)(.*)$")
APP_STORE_NOTE = " (App Store version)"


def split_front_matter(page: str) -> dict:
    match = re.match(r"\+\+\+\n(.*?)\n\+\+\+\n", page, re.DOTALL)
    if not match:
        raise ValueError("blog page has no +++ front matter")
    return tomllib.loads(match.group(1))


def keys_text(token: str) -> str:
    parts = token.split()
    if parts and parts[-1] == "space":
        return "".join(parts[:-1]) + " + space"
    return "".join(parts)


def without_inline_symbols(line: str) -> str:
    if not SYMBOL.search(line) or SYMBOL.match(line.lstrip("- ")):
        return line
    sentences = re.split(r"(?<=\.) ", line)
    return " ".join(sentence for sentence in sentences if not SYMBOL.search(sentence))


def plain(line: str) -> str:
    line = without_inline_symbols(line).replace(APP_STORE_NOTE, "")
    line = re.sub(r"<[^>]+>", "", line)
    line = re.sub(r"\*\*(.+?)\*\*", r"\1", line)
    line = re.sub(r"`(.+?)`", r"\1", line)
    line = SYMBOL.sub("", line)
    leading = LEADING_KEYS.match(line)
    if leading:
        keys = " ".join(keys_text(token) for token in KEYS.findall(leading.group(1)))
        rest = leading.group(2).strip()
        line = f"{keys} {rest}" if " - " in rest else f"{keys} - {rest}"
    line = KEYS.sub(lambda match: keys_text(match.group(1)), line).rstrip()
    return line[:-1].rstrip() if line.endswith("\\") else line


def paragraphs(text: str) -> list[str]:
    blocks: list[str] = []
    current: list[str] = []
    for line in text.splitlines():
        if not line.strip():
            if current:
                blocks.append("\n".join(current))
                current = []
            continue
        if line.startswith("- "):
            current.append("• " + plain(line[2:]))
        else:
            current.append(plain(line))
    if current:
        blocks.append("\n".join(current))
    return blocks


def section(title: str, summary: str, bullets: list[str], body: str) -> str:
    head = "\n".join([title.upper(), plain(summary), *bullets])
    return "\n\n".join([head, *paragraphs(body)])


def description_text(front_matter: dict) -> str:
    opening = front_matter.get("open", {})
    blocks = [opening.get("title", ""), *paragraphs(opening.get("body", ""))]
    for feature in front_matter.get("features", []):
        if feature.get("direct"):
            continue
        bullets = [f"• {browser['name']}" for browser in feature.get("browsers", [])]
        blocks.append(section(feature["title"], feature.get("summary", ""), bullets, feature.get("body", "")))
    for more in front_matter.get("more", []):
        if more.get("direct"):
            continue
        commands = [
            f"• {command['token']} - {command['text'].replace(APP_STORE_NOTE, '')}" for command in more.get("commands", []) if not command.get("direct")
        ]
        blocks.append(section(more["title"], more.get("summary", ""), commands, more.get("body", "")))
    if front_matter.get("requirement"):
        blocks.append(front_matter["requirement"])
    text = "\n\n".join(block for block in blocks if block) + "\n"
    if len(text) > DESCRIPTION_LIMIT:
        raise ValueError(f"description is {len(text)} characters, App Store limit is {DESCRIPTION_LIMIT}")
    return text


def promotional_text(front_matter: dict) -> str:
    text = front_matter.get("description", "").strip()
    if not text:
        raise ValueError("blog front matter has no description for the promotional text")
    if len(text) > PROMOTIONAL_TEXT_LIMIT:
        raise ValueError(f"promotional text is {len(text)} characters, App Store limit is {PROMOTIONAL_TEXT_LIMIT}")
    return text + "\n"


def release_notes_text(notes_path: str) -> str:
    spec = importlib.util.spec_from_file_location("release_notes", pathlib.Path(__file__).with_name("release-notes.py"))
    release_notes = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(release_notes)
    return release_notes.appstore_text(pathlib.Path(notes_path).read_text(encoding="utf-8")).strip()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--blog-page", required=True)
    parser.add_argument("--listing", required=True)
    parser.add_argument("--whats-new")
    args = parser.parse_args()
    try:
        front_matter = split_front_matter(open(args.blog_page, encoding="utf-8").read())
        description = description_text(front_matter)
        promotional = promotional_text(front_matter)
    except ValueError as error:
        sys.exit(f"{args.blog_page}: {error}")
    listing_path = pathlib.Path(args.listing)
    listing = json.loads(listing_path.read_text(encoding="utf-8"))
    listing["description"] = description.strip()
    listing["promotionalText"] = promotional.strip()
    if args.whats_new:
        listing["whatsNew"] = release_notes_text(args.whats_new)
    listing_path.write_text(json.dumps(listing, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
