import json
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "release-notes.py"
RELEASE_NOTES = pathlib.Path(__file__).resolve().parent.parent.parent / "release-notes"
FRONT_MATTER = '+++\ntitle = "Release Notes"\ndraft = false\n+++\n'
NOTES = "### New\n- Release notes in **Settings**.\n\n### Fixed\n- Crash when closing the last tab.\n"


class ReleaseNotesTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temporary_directory.name)
        self.notes = self.root / "notes.md"
        self.notes.write_text(NOTES)
        self.page = self.root / "release-notes.md"
        self.page.write_text(FRONT_MATTER)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def run_script(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], capture_output=True, text=True)

    def check(self, text):
        self.notes.write_text(text)
        return self.run_script("check", str(self.notes))

    def blog_add(self, version, date):
        result = self.run_script("blog-add", "--page", str(self.page), "--version", version, "--date", date, "--notes", str(self.notes))
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_check_accepts_sections_in_order(self):
        self.assertEqual(self.check(NOTES).returncode, 0)

    def test_check_accepts_single_line_first_release(self):
        self.assertEqual(self.check("Initial release.\n").returncode, 0)

    def test_check_rejects_unknown_section(self):
        result = self.check("### Added\n- Thing.\n")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("### Added", result.stderr)

    def test_check_rejects_sections_out_of_order(self):
        self.assertNotEqual(self.check("### Fixed\n- A.\n\n### New\n- B.\n").returncode, 0)

    def test_check_rejects_empty_section(self):
        self.assertNotEqual(self.check("### New\n\n### Fixed\n- A.\n").returncode, 0)

    def test_check_rejects_text_that_is_not_a_bullet(self):
        self.assertNotEqual(self.check("### New\nSome prose.\n").returncode, 0)

    def test_check_rejects_bullets_without_section(self):
        self.assertNotEqual(self.check("- First release.\n").returncode, 0)

    def test_check_rejects_empty_file(self):
        self.assertNotEqual(self.check("\n").returncode, 0)

    def test_repository_notes_pass_check(self):
        for notes in sorted(RELEASE_NOTES.glob("*.md")):
            with self.subTest(notes=notes.name):
                result = self.run_script("check", str(notes))
                self.assertEqual(result.returncode, 0, result.stderr)

    def test_appstore_renders_plain_text(self):
        result = self.run_script("appstore", str(self.notes))

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "New:\n• Release notes in Settings.\n\nFixed:\n• Crash when closing the last tab.\n")

    def test_appstore_keeps_first_release_line(self):
        self.notes.write_text("Initial release.\n")

        self.assertEqual(self.run_script("appstore", str(self.notes)).stdout, "Initial release.\n")

    def what_to_test(self, review_notes):
        review = self.root / "review-information.json"
        review.write_text(json.dumps({"notes": review_notes}))
        return self.run_script("what-to-test", str(self.notes), "--review-information", str(review), "--feedback-email", "help@example.com")

    def test_what_to_test_combines_notes_try_list_and_feedback(self):
        result = self.what_to_test("ABOUT\nAn app.\n\nWHAT TO TRY\n1. Open it.\n2. Search.\n\nACCOUNT\nNone.\n")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(
            result.stdout,
            "WHAT'S NEW\nNew:\n• Release notes in Settings.\n\nFixed:\n• Crash when closing the last tab.\n\n"
            "WHAT TO TRY\n1. Open it.\n2. Search.\n\n"
            "FEEDBACK\nUse Send Beta Feedback in TestFlight, or email help@example.com.\n",
        )

    def test_what_to_test_reads_try_list_at_end_of_file(self):
        self.notes.write_text("Initial release.\n")

        result = self.what_to_test("ABOUT\nAn app.\n\nWHAT TO TRY\n1. Open it.\n")

        self.assertIn("WHAT'S NEW\nInitial release.\n\nWHAT TO TRY\n1. Open it.\n\nFEEDBACK", result.stdout)

    def test_what_to_test_requires_try_section(self):
        result = self.what_to_test("ABOUT\nAn app.\n")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("WHAT TO TRY", result.stderr)

    def test_blog_add_puts_version_and_date_above_notes(self):
        self.blog_add("1.0.1", "2026-10-13")

        self.assertEqual(self.page.read_text(), FRONT_MATTER + "\n## 1.0.1\n\n*13 October 2026*\n\n" + NOTES)

    def test_blog_add_puts_newest_version_first(self):
        self.blog_add("1.0.0", "2026-10-01")
        self.blog_add("1.0.1", "2026-10-13")

        text = self.page.read_text()
        self.assertLess(text.index("## 1.0.1"), text.index("## 1.0.0"))

    def test_blog_add_replaces_existing_version(self):
        self.page.write_text(FRONT_MATTER + "\n## 1.0.0\n\n*Unreleased*\n\nInitial release.\n")

        self.blog_add("1.0.0", "2026-10-13")

        self.assertEqual(self.page.read_text(), FRONT_MATTER + "\n## 1.0.0\n\n*13 October 2026*\n\n" + NOTES)

    def test_blog_remove_restores_previous_page(self):
        self.blog_add("1.0.0", "2026-10-01")
        before = self.page.read_text()
        self.blog_add("1.0.1", "2026-10-13")

        result = self.run_script("blog-remove", "--page", str(self.page), "--version", "1.0.1")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.page.read_text(), before)

    def test_blog_remove_missing_version_leaves_page_unchanged(self):
        self.blog_add("1.0.0", "2026-10-01")
        before = self.page.read_text()

        result = self.run_script("blog-remove", "--page", str(self.page), "--version", "2.0.0")

        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("2.0.0 is not in the release notes", result.stdout)
        self.assertEqual(self.page.read_text(), before)


if __name__ == "__main__":
    unittest.main()
