import pathlib
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET

SCRIPTS = pathlib.Path(__file__).resolve().parent.parent
ADD = SCRIPTS / "appcast-add-item.py"
REMOVE = SCRIPTS / "appcast-remove-item.py"
SPARKLE = "{http://www.andymatuschak.org/xml-namespaces/sparkle}"
EMPTY_APPCAST = """<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>__APP__ Changelog</title>
    </channel>
</rss>
"""


class AppcastRemoveItemTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temporary_directory.name)
        self.appcast = self.root / "appcast.xml"
        self.appcast.write_text(EMPTY_APPCAST)
        self.notes = self.root / "notes.md"
        self.notes.write_text("- Fix\n")

    def tearDown(self):
        self.temporary_directory.cleanup()

    def add(self, build, version):
        subprocess.run(
            [
                sys.executable, str(ADD),
                "--appcast", str(self.appcast), "--title", f"__APP__ {version}", "--build", build,
                "--version", version, "--min-os", "15.5",
                "--url", f"https://example.com/__APP__-{version}.dmg",
                "--signature-line", 'sparkle:edSignature="c2ln==" length="1"', "--notes", str(self.notes),
            ],
            check=True,
        )

    def remove(self, version):
        return subprocess.run(
            [sys.executable, str(REMOVE), "--appcast", str(self.appcast), "--version", version],
            capture_output=True, text=True,
        )

    def versions(self):
        root = ET.parse(self.appcast).getroot()
        return [item.findtext(f"{SPARKLE}shortVersionString") for item in root.findall("./channel/item")]

    def test_removes_only_matching_item(self):
        self.add("1", "1.0")
        self.add("2", "1.0.1")

        result = self.remove("1.0.1")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.versions(), ["1.0"])

    def test_removing_last_item_restores_original_file(self):
        self.add("1", "1.0")

        self.remove("1.0")

        self.assertEqual(self.appcast.read_text(), EMPTY_APPCAST)

    def test_missing_version_leaves_file_unchanged(self):
        self.add("1", "1.0")
        before = self.appcast.read_text()

        result = self.remove("2.0")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("2.0 is not in the appcast", result.stdout)
        self.assertEqual(self.appcast.read_text(), before)


if __name__ == "__main__":
    unittest.main()
