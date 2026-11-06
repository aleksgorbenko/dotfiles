import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "homebrew_cask.py"
CASK = """cask "__SLUG__" do
  version "1.0.0"
  sha256 :no_check

  url "https://example.com/__SLUG__-v#{version}/__APP__-#{version}.dmg"
end
"""
CHECKSUM = "a" * 64


class HomebrewCaskTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.cask = pathlib.Path(self.temporary_directory.name) / "__SLUG__.rb"
        self.cask.write_text(CASK)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def update(self, version, checksum):
        return subprocess.run(
            [sys.executable, str(SCRIPT), "--cask", str(self.cask), "--version", version, "--sha256", checksum],
            capture_output=True, text=True,
        )

    def test_sets_version_and_checksum(self):
        result = self.update("1.2.0", CHECKSUM)

        self.assertEqual(result.returncode, 0, result.stderr)
        text = self.cask.read_text()
        self.assertIn('  version "1.2.0"\n', text)
        self.assertIn(f'  sha256 "{CHECKSUM}"\n', text)
        self.assertIn("__SLUG__-v#{version}", text)

    def test_replaces_an_existing_checksum(self):
        self.update("1.2.0", CHECKSUM)

        self.update("1.3.0", "b" * 64)

        self.assertIn(f'  sha256 "{"b" * 64}"\n', self.cask.read_text())

    def test_rejects_a_malformed_checksum(self):
        result = self.update("1.2.0", "not-a-checksum")

        self.assertNotEqual(result.returncode, 0)
        self.assertIn("sha256", result.stderr)


if __name__ == "__main__":
    unittest.main()
