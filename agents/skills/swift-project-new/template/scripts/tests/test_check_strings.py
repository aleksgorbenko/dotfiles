import pathlib
import sys
import unittest
from unittest import mock

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

import check_strings
from check_strings import key_problems


class KeyProblemsTests(unittest.TestCase):
    def test_accepts_keys_that_end_in_a_role(self):
        keys = ["onboardingShortcutTitle", "settingsLaunchAtLoginLabel", "menuQuitItem", "cancelButton"]
        self.assertEqual(key_problems(keys), [])

    def test_reports_keys_without_a_role(self):
        self.assertEqual(key_problems(["aboutTagline"]), ["aboutTagline: end with a role (Title, Subtitle, Label, …)"])

    def test_reports_banned_words(self):
        with mock.patch.dict(check_strings.BANNED, {"hotkey": "shortcut"}, clear=True):
            self.assertEqual(key_problems(["settingsHotkeyLabel"]), ["settingsHotkeyLabel: use 'shortcut', not 'hotkey'"])


if __name__ == "__main__":
    unittest.main()
