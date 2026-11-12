import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from appstore_validate import validate_lines

WIDTH = 80
NARROW_WIDTH = 26

REPORT = {
    "versionString": "1.0.0",
    "summary": {"errors": 1, "warnings": 1, "infos": 1, "blocking": 1},
    "remediation": {
        "steps": [
            {"blocking": True, "severity": "error", "message": "version is not editable",
             "remediation": "Use an editable version state before submission"},
            {"blocking": False, "severity": "warning", "message": "keyword repeats the app name",
             "remediation": "Drop the app name from the keywords"},
            {"blocking": False, "severity": "info", "message": "App Privacy publish state is not verifiable",
             "remediation": "Confirm App Privacy is published"},
        ]
    },
}


class ValidateLinesTests(unittest.TestCase):
    def test_lists_each_step_with_its_fix_under_a_summary(self):
        self.assertEqual(
            validate_lines(REPORT, width=WIDTH),
            [
                "App Store submission check: 1.0.0",
                "  1 blocking, 1 warning, 1 note",
                "",
                "  BLOCKING  version is not editable",
                "            fix: Use an editable version state before submission",
                "",
                "  warning   keyword repeats the app name",
                "            fix: Drop the app name from the keywords",
                "",
                "  note      App Privacy publish state is not verifiable",
                "            fix: Confirm App Privacy is published",
            ],
        )

    def test_wraps_long_text_under_its_column(self):
        report = {
            "versionString": "1.0.0",
            "summary": {"errors": 0, "warnings": 0, "infos": 1, "blocking": 0},
            "remediation": {"steps": [{"blocking": False, "severity": "info", "message": "one two three four five",
                                       "remediation": "six"}]},
        }

        self.assertEqual(
            validate_lines(report, width=NARROW_WIDTH)[3:5],
            ["  note      one two three", "            four five"],
        )

    def test_reports_ready_when_nothing_is_found(self):
        report = {"versionString": "1.1.0", "summary": {"errors": 0, "warnings": 0, "infos": 0, "blocking": 0},
                  "remediation": {"steps": []}}

        self.assertEqual(
            validate_lines(report, width=WIDTH),
            ["App Store submission check: 1.1.0", "  ready to submit"],
        )


if __name__ == "__main__":
    unittest.main()
