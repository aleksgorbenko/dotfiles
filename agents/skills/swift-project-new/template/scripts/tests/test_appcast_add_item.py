import pathlib
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "appcast-add-item.py"
SPARKLE = "{http://www.andymatuschak.org/xml-namespaces/sparkle}"
EMPTY_APPCAST = """<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>__APP__ Changelog</title>
    </channel>
</rss>
"""
SIGNATURE_LINE = 'sparkle:edSignature="c2lnbmF0dXJl==" length="4995667"'


class AppcastAddItemTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temporary_directory.name)
        self.appcast = self.root / "appcast.xml"
        self.appcast.write_text(EMPTY_APPCAST)
        self.notes = self.root / "notes.md"
        self.notes.write_text("- **Faster** search\n- Fix `b␣` scope\n")

    def tearDown(self):
        self.temporary_directory.cleanup()

    def add(self, build, version, signature_line=SIGNATURE_LINE):
        return subprocess.run(
            [
                sys.executable, str(SCRIPT),
                "--appcast", str(self.appcast), "--title", f"__APP__ {version}", "--build", build,
                "--version", version, "--min-os", "15.5",
                "--url", f"https://example.com/__APP__-{version}.dmg",
                "--signature-line", signature_line, "--notes", str(self.notes),
            ],
            capture_output=True, text=True,
        )

    def items(self):
        return ET.parse(self.appcast).getroot().findall("./channel/item")

    def test_adds_item_with_sparkle_fields(self):
        result = self.add("1", "1.0")

        self.assertEqual(result.returncode, 0, result.stderr)
        [item] = self.items()
        self.assertEqual(item.findtext(f"{SPARKLE}version"), "1")
        self.assertEqual(item.findtext(f"{SPARKLE}shortVersionString"), "1.0")
        self.assertEqual(item.findtext(f"{SPARKLE}minimumSystemVersion"), "15.5")
        enclosure = item.find("enclosure")
        self.assertEqual(enclosure.get("url"), "https://example.com/__APP__-1.0.dmg")
        self.assertEqual(enclosure.get("length"), "4995667")
        self.assertEqual(enclosure.get(f"{SPARKLE}edSignature"), "c2lnbmF0dXJl==")

    def test_renders_notes_as_html_list(self):
        self.add("1", "1.0")

        [item] = self.items()
        self.assertEqual(
            item.findtext("description"),
            "<ul>\n<li><b>Faster</b> search</li>\n<li>Fix <code>b␣</code> scope</li>\n</ul>",
        )

    def test_renders_sections_as_headings(self):
        self.notes.write_text("### New\n- Thing.\n\n### Fixed\n- Bug.\n")

        self.add("1", "1.0.0")

        [item] = self.items()
        self.assertEqual(
            item.findtext("description"),
            "<h3>New</h3>\n<ul>\n<li>Thing.</li>\n</ul>\n<h3>Fixed</h3>\n<ul>\n<li>Bug.</li>\n</ul>",
        )

    def test_inserts_newest_item_first(self):
        self.add("1", "1.0")
        self.add("2", "1.0.1")

        self.assertEqual([item.findtext(f"{SPARKLE}version") for item in self.items()], ["2", "1"])

    def test_rejects_duplicate_build(self):
        self.add("1", "1.0")

        result = self.add("1", "1.0")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("build 1 is already in the appcast", result.stderr)
        self.assertEqual(len(self.items()), 1)

    def test_rejects_unparseable_signature_line(self):
        result = self.add("1", "1.0", signature_line="garbage")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("cannot parse sign_update output", result.stderr)
        self.assertEqual(self.items(), [])


if __name__ == "__main__":
    unittest.main()
