import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "appstore-copy.py"
PAGE = """+++
title = "__APP__"
description = "__APP__ is a launcher for your browser tabs. Everything local - no cloud."
requirement = "Requires macOS 15 or later"

[open]
title = "Single search for tabs"
body = \'\'\'
__APP__ runs in the background.\\
Summon it from anywhere.

Local, no account.
\'\'\'

[[features]]
title = "Scoped Search"
summary = "Start with a letter and a space."
body = \'\'\'
- [[sf:bookmark]] [[b space]] Bookmarks only
- [[↩]] **Activate** - jump to the tab.
- [[⌘ ⌫]] **Close** - close it.

<span class="footnote">Tabs need their browser open.</span>

The icon shows the scope. [[sf:magnifyingglass]] means everywhere. Press [[⌫]] to go back.
\'\'\'

[[features]]
title = "Browser Support"
summary = "Works with the browsers you use."
body = '''
Firefox: history and bookmarks only.

> [!TIP]
> Messy bookmarks? [Organise them](/guide/) first.
'''
browsers = [
  { id = "safari", name = "Safari" },
  { id = "firefox", name = "Firefox" },
]

[[more]]
id = "commands"
title = "Built-in Commands"
summary = "Type [[/]] in the launcher to run a command."
commands = [
  { token = "/settings", text = "Open __APP__ Settings" },
  { token = "/check-updates", text = "Check for updates", direct = true },
  { token = "/review", text = "Write a review (App Store version)" },
]

[[more]]
id = "cli"
title = "Command Line Interface"
summary = "Script __APP__ from Terminal."
direct = true
+++

Tips go here.
"""


class AppStoreCopyTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temporary_directory.name)
        self.page = self.root / "_index.md"
        self.page.write_text(PAGE)
        self.listing = self.root / "en-GB.json"
        self.listing.write_text(json.dumps({"keywords": "tabs", "supportUrl": "https://example.com"}))

    def tearDown(self):
        self.temporary_directory.cleanup()

    def read_listing(self):
        return json.loads(self.listing.read_text())

    def generate(self, *extra):
        return subprocess.run(
            [
                sys.executable, str(SCRIPT), "--blog-page", str(self.page),
                "--listing", str(self.listing), *extra,
            ],
            capture_output=True, text=True,
        )

    def test_description_follows_the_page_sections(self):
        result = self.generate()

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            self.read_listing()["description"],
            "Single search for tabs\n\n"
            "__APP__ runs in the background.\nSummon it from anywhere.\n\n"
            "Local, no account.\n\n"
            "SCOPED SEARCH\nStart with a letter and a space.\n\n"
            "• b + space - Bookmarks only\n"
            "• ↩ Activate - jump to the tab.\n"
            "• ⌘⌫ Close - close it.\n\n"
            "Tabs need their browser open.\n\n"
            "The icon shows the scope. Press ⌫ to go back.\n\n"
            "BROWSER SUPPORT\nWorks with the browsers you use.\n"
            "• Safari\n• Firefox\n\n"
            "Firefox: history and bookmarks only.\n\n"
            "BUILT-IN COMMANDS\nType / in the launcher to run a command.\n"
            "• /settings - Open __APP__ Settings\n"
            "• /review - Write a review\n\n"
            "Requires macOS 15 or later",
        )

    def test_direct_only_items_are_left_out(self):
        self.generate()

        text = self.read_listing()["description"]
        self.assertNotIn("COMMAND LINE", text)
        self.assertNotIn("check-updates", text)
        self.assertNotIn("Tips go here", text)

    def test_callouts_are_left_out(self):
        self.generate()

        text = self.read_listing()["description"]
        self.assertNotIn("[!TIP]", text)
        self.assertNotIn("Messy bookmarks", text)

    def test_whats_new_comes_from_the_release_notes(self):
        notes = self.root / "1.1.0.md"
        notes.write_text("### Fixed\n\n- Tabs open faster.\n")

        result = self.generate("--whats-new", str(notes))

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Tabs open faster.", self.read_listing()["whatsNew"])

    def test_other_listing_fields_are_kept(self):
        self.generate()

        self.assertEqual(self.read_listing()["keywords"], "tabs")
        self.assertEqual(self.read_listing()["supportUrl"], "https://example.com")

    def test_promotional_text_comes_from_front_matter_description(self):
        self.generate()

        self.assertEqual(
            self.read_listing()["promotionalText"],
            "__APP__ is a launcher for your browser tabs. Everything local - no cloud.",
        )

    def test_promotional_text_prefers_front_matter_promotional_text(self):
        self.page.write_text(
            PAGE.replace('requirement = "', 'promotional_text = "Early-bird price: 43% off."\nrequirement = "', 1)
        )

        self.generate()

        self.assertEqual(self.read_listing()["promotionalText"], "Early-bird price: 43% off.")

    def test_rejects_promotional_text_over_170_characters(self):
        self.page.write_text(PAGE.replace("Everything local - no cloud.", "x" * 170))

        result = self.generate()

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("170", result.stderr)


if __name__ == "__main__":
    unittest.main()
