import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from distribution_status import Check, appcast_check, homebrew_check, status_lines, website_check

def cask(version):
    return f'cask "sample" do\n  version "{version}"\n  sha256 "0"\nend\n'


DOWNLOAD = "https://example.com/apps/sample/download/v1.2.0/Sample-1.2.0.dmg"
APPCAST = f"""<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <item>
      <title>Sample 1.1.0</title>
      <sparkle:version>3</sparkle:version>
      <sparkle:shortVersionString>1.1.0</sparkle:shortVersionString>
      <enclosure url="https://example.com/old.dmg" length="1" type="application/octet-stream"/>
    </item>
    <item>
      <title>Sample 1.2.0</title>
      <sparkle:version>4</sparkle:version>
      <sparkle:shortVersionString>1.2.0</sparkle:shortVersionString>
      <enclosure url="{DOWNLOAD}" length="1" type="application/octet-stream"/>
    </item>
  </channel>
</rss>
"""
EMPTY_APPCAST = '<rss version="2.0"><channel><title>Sample</title></channel></rss>'
CHECKOUT = "https://store.example.com/checkout/buy/abc"
APP_STORE = "https://apps.apple.com/app/id123"


class AppcastCheckTests(unittest.TestCase):
    def test_latest_item_must_be_this_version_and_link_its_download(self):
        self.assertEqual(appcast_check(APPCAST, "1.2.0", DOWNLOAD), Check("ok", "Appcast", "1.2.0 (build 4)"))

    def test_older_latest_item_is_a_problem(self):
        check = appcast_check(APPCAST, "1.3.0", DOWNLOAD)
        self.assertEqual(check.state, "problem")
        self.assertIn("latest is 1.2.0", check.detail)

    def test_wrong_download_link_is_a_problem(self):
        check = appcast_check(APPCAST, "1.2.0", "https://example.com/other.dmg")
        self.assertEqual(check, Check("problem", "Appcast", f"1.2.0 links {DOWNLOAD}"))

    def test_empty_feed_is_a_problem(self):
        self.assertEqual(appcast_check(EMPTY_APPCAST, "1.2.0", DOWNLOAD), Check("problem", "Appcast", "no items"))


class WebsiteCheckTests(unittest.TestCase):
    def test_every_link_present_is_ok(self):
        page = f'<a href="{CHECKOUT}">Buy</a><a href="{APP_STORE}">App Store</a><a href="{DOWNLOAD}">Try</a>'
        self.assertEqual(
            website_check(page, [CHECKOUT, APP_STORE, DOWNLOAD]),
            Check("ok", "Website", "checkout, App Store and download links present"),
        )

    def test_names_the_missing_links(self):
        page = f'<a href="{APP_STORE}">App Store</a>'
        self.assertEqual(
            website_check(page, [CHECKOUT, APP_STORE, DOWNLOAD]),
            Check("problem", "Website", f"missing {CHECKOUT}, {DOWNLOAD}"),
        )


class HomebrewCheckTests(unittest.TestCase):
    def test_same_version_is_ok(self):
        self.assertEqual(homebrew_check(cask("1.2.0"), "1.2.0"), Check("ok", "Homebrew", "1.2.0"))

    def test_older_version_is_a_problem(self):
        self.assertEqual(homebrew_check(cask("1.1.0"), "1.2.0"), Check("problem", "Homebrew", "has 1.1.0"))

    def test_missing_cask_is_a_problem(self):
        self.assertEqual(homebrew_check(None, "1.2.0"), Check("problem", "Homebrew", "no cask in the tap"))


class StatusLinesTests(unittest.TestCase):
    def test_lists_each_check_under_a_summary(self):
        checks = [
            Check("ok", "App Store", "1.2.0 READY_FOR_SALE"),
            Check("problem", "GitHub release", "no release v1.2.0"),
            Check("note", "Homebrew", "no cask yet"),
        ]
        self.assertEqual(
            status_lines("Sample", "1.2.0", checks),
            [
                "Distribution status: Sample 1.2.0",
                "  1 ok, 1 problem, 1 note",
                "",
                "  ok        App Store       1.2.0 READY_FOR_SALE",
                "  PROBLEM   GitHub release  no release v1.2.0",
                "  note      Homebrew        no cask yet",
            ],
        )


if __name__ == "__main__":
    unittest.main()
