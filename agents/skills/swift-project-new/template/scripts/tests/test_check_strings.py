import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_strings import key_problems


class KeyProblemsTests(unittest.TestCase):
    def test_accepts_keys_that_end_in_a_role(self):
        keys = ["onboardingGlobalShortcutTitle", "settingsLaunchAtLoginLabel", "menuQuitItem", "cancelButton",
                "systemSettingsKeyboardShortcutsPaneName", "settingsResetAccessAllBrowsersSubject"]
        self.assertEqual(key_problems(keys), [])

    def test_reports_keys_without_a_role(self):
        self.assertEqual(key_problems(["aboutTagline"]), ["aboutTagline: end with a role (Title, Subtitle, Label, …)"])

    def test_reports_banned_words(self):
        self.assertEqual(
            key_problems(["welcomeHotkeyTitle"]),
            ["welcomeHotkeyTitle: use 'keyboard shortcut', not 'hotkey'",
             "welcomeHotkeyTitle: use 'onboarding', not 'welcome'"],
        )

if __name__ == "__main__":
    unittest.main()
