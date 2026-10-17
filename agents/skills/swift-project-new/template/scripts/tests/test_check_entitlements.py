import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_entitlements import entitlement_differences

SANDBOX = "com.apple.security.app-sandbox"
EVENTS = "com.apple.security.temporary-exception.apple-events"


class EntitlementDifferencesTests(unittest.TestCase):
    def test_identical_entitlements_have_no_differences(self):
        expected = {SANDBOX: True, EVENTS: ["com.apple.Safari"]}
        self.assertEqual(entitlement_differences(expected, dict(expected)), [])

    def test_ignores_identifiers_added_by_signing(self):
        actual = {
            SANDBOX: True,
            "com.apple.application-identifier": "TEAM.dev.example",
            "com.apple.developer.team-identifier": "TEAM",
        }
        self.assertEqual(entitlement_differences({SANDBOX: True}, actual), [])

    def test_reports_added_removed_and_changed_keys(self):
        expected = {SANDBOX: True, EVENTS: ["com.apple.Safari"]}
        actual = {EVENTS: ["com.apple.Safari", "org.mozilla.firefox"], "com.apple.security.get-task-allow": True}
        self.assertEqual(
            entitlement_differences(expected, actual),
            [
                "added: com.apple.security.get-task-allow",
                f"removed: {SANDBOX}",
                f"changed: {EVENTS}",
            ],
        )


if __name__ == "__main__":
    unittest.main()
