#!/usr/bin/env python3
import argparse
import datetime
import email.utils
import html
import re
import sys
import xml.etree.ElementTree as ET


def notes_html(markdown):
    out, in_list = [], False
    for line in markdown.splitlines():
        line = line.strip()
        text = html.escape(line[2:] if line.startswith("- ") else line)
        text = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", text)
        text = re.sub(r"`(.+?)`", r"<code>\1</code>", text)
        if line.startswith("- "):
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f"<li>{text}</li>")
            continue
        if in_list:
            out.append("</ul>")
            in_list = False
        if line.startswith("### "):
            out.append(f"<h3>{html.escape(line[4:])}</h3>")
        elif line:
            out.append(f"<p>{text}</p>")
    if in_list:
        out.append("</ul>")
    return "\n".join(out)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--appcast", required=True)
    parser.add_argument("--title", required=True)
    parser.add_argument("--build", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--min-os", required=True)
    parser.add_argument("--url", required=True)
    parser.add_argument("--signature-line", required=True)
    parser.add_argument("--notes", required=True)
    args = parser.parse_args()

    signature = re.search(r'sparkle:edSignature="([^"]+)"', args.signature_line)
    length = re.search(r'length="(\d+)"', args.signature_line)
    if not signature or not length:
        sys.exit(f"cannot parse sign_update output: {args.signature_line!r}")

    xml = open(args.appcast, encoding="utf-8").read()
    if f"<sparkle:version>{args.build}</sparkle:version>" in xml:
        sys.exit(f"build {args.build} is already in the appcast")

    notes = notes_html(open(args.notes, encoding="utf-8").read()).replace("]]>", "]]]]><![CDATA[>")
    published = email.utils.format_datetime(datetime.datetime.now(datetime.timezone.utc))
    item = f"""        <item>
            <title>{html.escape(args.title)}</title>
            <pubDate>{published}</pubDate>
            <sparkle:version>{args.build}</sparkle:version>
            <sparkle:shortVersionString>{args.version}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>{args.min_os}</sparkle:minimumSystemVersion>
            <description><![CDATA[{notes}]]></description>
            <enclosure url="{html.escape(args.url)}" length="{length.group(1)}" type="application/octet-stream" sparkle:edSignature="{signature.group(1)}"/>
        </item>
"""
    marker = re.search(r"^\s*<item>", xml, re.MULTILINE) or re.search(r"^\s*</channel>", xml, re.MULTILINE)
    updated = xml[: marker.start()] + item + xml[marker.start() :]
    ET.fromstring(updated)
    open(args.appcast, "w", encoding="utf-8").write(updated)


if __name__ == "__main__":
    main()
