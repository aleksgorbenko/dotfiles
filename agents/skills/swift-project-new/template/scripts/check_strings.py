#!/usr/bin/env python3
import json
import pathlib
import re
import sys

ROLES = ("TabLabel", "ColumnHeader", "PaneName", "Subtitle", "Title", "Label", "Button", "Item", "Link",
         "Message", "Hint", "Subject")
BANNED = {}


def key_problems(keys):
    problems = []
    for key in keys:
        if not key.endswith(ROLES):
            problems.append(f"{key}: end with a role (Title, Subtitle, Label, …)")
        words = [word.lower() for word in re.findall(r"[a-z]+|[A-Z][a-z]*", key)]
        for banned, preferred in sorted(BANNED.items()):
            if banned in words:
                problems.append(f"{key}: use '{preferred}', not '{banned}'")
    return problems


def main():
    catalog = json.loads(pathlib.Path(sys.argv[1]).read_text())
    problems = key_problems(catalog["strings"].keys())
    for problem in problems:
        print(problem)
    if problems:
        sys.exit(1)


if __name__ == "__main__":
    main()
