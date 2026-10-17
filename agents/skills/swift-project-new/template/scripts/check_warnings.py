#!/usr/bin/env python3
import pathlib
import re
import sys

WARNING = re.compile(r"^(/[^:]+\.swift):\d+:\d+: warning: ")
EXCLUDED_PARTS = ("/SourcePackages/", "/.build/")


def project_warnings(log, root):
    found = set()
    for line in log.splitlines():
        match = WARNING.match(line)
        if not match:
            continue
        path = match.group(1)
        if path.startswith(root) and not any(part in path for part in EXCLUDED_PARTS):
            found.add(line.strip())
    return sorted(found)


def main():
    log_path = sys.argv[1]
    root = str(pathlib.Path(__file__).resolve().parent.parent) + "/"
    warnings = project_warnings(pathlib.Path(log_path).read_text(errors="replace"), root)
    for warning in warnings:
        print(warning)
    if warnings:
        print(f"{len(warnings)} warning(s) in project sources")
        sys.exit(1)
    print(f"No warnings in project sources ({log_path})")


if __name__ == "__main__":
    main()
