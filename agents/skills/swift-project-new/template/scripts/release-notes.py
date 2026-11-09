#!/usr/bin/env python3
import argparse
import datetime
import json
import re
import sys

SECTIONS = ["New", "Improved", "Fixed"]


def parse(text):
    lines = [line.rstrip() for line in text.splitlines() if line.strip()]
    if len(lines) == 1 and not lines[0].startswith(("#", "- ")):
        return lines[0], []
    errors, sections, order = [], [], -1
    for line in lines:
        heading = re.fullmatch(r"### (.+)", line)
        if heading:
            name = heading.group(1)
            if name not in SECTIONS:
                errors.append(f"unknown section {line!r} - use ### {', ### '.join(SECTIONS)}")
                continue
            if SECTIONS.index(name) <= order:
                errors.append(f"section {line!r} is out of order - use {', '.join(SECTIONS)}")
            order = SECTIONS.index(name)
            sections.append((name, []))
        elif not line.startswith("- "):
            errors.append(f"not a bullet: {line!r}")
        elif not sections:
            errors.append(f"bullet before any section: {line!r}")
        else:
            sections[-1][1].append(line[2:])
    if not lines:
        errors.append("release notes are empty")
    errors += [f"section '### {name}' has no bullets" for name, bullets in sections if not bullets]
    if errors:
        raise ValueError("\n".join(errors))
    return None, sections


def plain(text):
    return re.sub(r"\*\*(.+?)\*\*|`(.+?)`", lambda match: match.group(1) or match.group(2), text)


def appstore_text(text):
    first_release, sections = parse(text)
    if first_release:
        return first_release + "\n"
    return "\n".join(f"{name}:\n" + "".join(f"• {plain(bullet)}\n" for bullet in bullets) for name, bullets in sections)


def review_section(review_notes, title):
    lines, inside = [], False
    for line in review_notes.splitlines():
        if re.fullmatch(r"[A-Z][A-Z ']+", line.strip()):
            inside = line.strip() == title
            continue
        if inside:
            lines.append(line)
    section = "\n".join(lines).strip()
    if not section:
        raise ValueError(f"review notes have no {title} section")
    return section


def what_to_test_text(text, review_notes, feedback_email):
    return (
        f"WHAT'S NEW\n{appstore_text(text)}\n"
        f"WHAT TO TRY\n{review_section(review_notes, 'WHAT TO TRY')}\n\n"
        f"FEEDBACK\nUse Send Beta Feedback in TestFlight, or email {feedback_email}.\n"
    )


def split_page(page):
    match = re.match(r"\+\+\+\n.*?\n\+\+\+\n", page, re.DOTALL)
    if not match:
        sys.exit("release notes page has no +++ front matter")
    front_matter, body = page[: match.end()], page[match.end() :]
    preamble, sections = [], []
    for line in body.splitlines(keepends=True):
        if line.startswith("## "):
            sections.append([line])
        elif sections:
            sections[-1].append(line)
        else:
            preamble.append(line)
    return front_matter, "".join(preamble).strip(), ["".join(section).strip() + "\n" for section in sections]


def join_page(front_matter, preamble, sections):
    blocks = ([preamble + "\n"] if preamble else []) + sections
    return front_matter + "".join("\n" + block for block in blocks)


def section_version(section):
    return section.splitlines()[0][3:].strip()


def blog_add(page_path, version, date, notes_path):
    notes = open(notes_path, encoding="utf-8").read()
    parse(notes)
    day = datetime.date.fromisoformat(date)
    front_matter, preamble, sections = split_page(open(page_path, encoding="utf-8").read())
    sections = [section for section in sections if section_version(section) != version]
    entry = f"## {version}\n\n*{day.day} {day:%B %Y}*\n\n{notes.strip()}\n"
    open(page_path, "w", encoding="utf-8").write(join_page(front_matter, preamble, [entry] + sections))


def blog_remove(page_path, version):
    front_matter, preamble, sections = split_page(open(page_path, encoding="utf-8").read())
    kept = [section for section in sections if section_version(section) != version]
    if len(kept) == len(sections):
        print(f"{version} is not in the release notes")
        return
    open(page_path, "w", encoding="utf-8").write(join_page(front_matter, preamble, kept))


def main():
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("check").add_argument("notes")
    commands.add_parser("appstore").add_argument("notes")
    testing = commands.add_parser("what-to-test")
    testing.add_argument("notes")
    testing.add_argument("--review-information", required=True)
    testing.add_argument("--feedback-email", required=True)
    add = commands.add_parser("blog-add")
    add.add_argument("--page", required=True)
    add.add_argument("--version", required=True)
    add.add_argument("--date", required=True)
    add.add_argument("--notes", required=True)
    remove = commands.add_parser("blog-remove")
    remove.add_argument("--page", required=True)
    remove.add_argument("--version", required=True)
    args = parser.parse_args()

    try:
        if args.command == "check":
            parse(open(args.notes, encoding="utf-8").read())
        elif args.command == "appstore":
            sys.stdout.write(appstore_text(open(args.notes, encoding="utf-8").read()))
        elif args.command == "what-to-test":
            review = json.load(open(args.review_information, encoding="utf-8"))["notes"]
            sys.stdout.write(what_to_test_text(open(args.notes, encoding="utf-8").read(), review, args.feedback_email))
        elif args.command == "blog-add":
            blog_add(args.page, args.version, args.date, args.notes)
        else:
            blog_remove(args.page, args.version)
    except ValueError as error:
        sys.exit(f"{getattr(args, 'notes', '')}: {error}")


if __name__ == "__main__":
    main()
