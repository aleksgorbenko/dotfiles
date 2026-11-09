#!/usr/bin/env python3
import argparse
import pathlib
import re
import sys

CHECKSUM = re.compile(r"^[0-9a-f]{64}$")


def updated(cask: str, version: str, checksum: str) -> str:
    cask = re.sub(r'^  version ".*"$', f'  version "{version}"', cask, count=1, flags=re.MULTILINE)
    return re.sub(r"^  sha256 .*$", f'  sha256 "{checksum}"', cask, count=1, flags=re.MULTILINE)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--cask", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--sha256", required=True)
    args = parser.parse_args()
    if not CHECKSUM.match(args.sha256):
        sys.exit(f"sha256 must be 64 lowercase hex characters, got {args.sha256!r}")
    path = pathlib.Path(args.cask)
    path.write_text(updated(path.read_text(encoding="utf-8"), args.version, args.sha256), encoding="utf-8")


if __name__ == "__main__":
    main()
