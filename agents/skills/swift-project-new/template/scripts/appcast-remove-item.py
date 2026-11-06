#!/usr/bin/env python3
import argparse
import re
import xml.etree.ElementTree as ET


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--appcast", required=True)
    parser.add_argument("--version", required=True)
    args = parser.parse_args()

    xml = open(args.appcast, encoding="utf-8").read()
    pattern = re.compile(
        rf"^[ \t]*<item>(?:(?!</item>).)*<sparkle:shortVersionString>{re.escape(args.version)}</sparkle:shortVersionString>.*?</item>\n",
        re.MULTILINE | re.DOTALL,
    )
    updated, count = pattern.subn("", xml)
    if count == 0:
        print(f"{args.version} is not in the appcast")
        return
    ET.fromstring(updated)
    open(args.appcast, "w", encoding="utf-8").write(updated)


if __name__ == "__main__":
    main()
