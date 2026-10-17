import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_warnings import project_warnings

ROOT = "/repo/"


class ProjectWarningsTests(unittest.TestCase):
    def test_reports_each_project_warning_once(self):
        log = "\n".join([
            "/repo/bukku/App/WindowOpener.swift:65:19: warning: call to main actor-isolated method",
            "/repo/bukku/App/WindowOpener.swift:65:19: warning: call to main actor-isolated method",
            "/repo/Packages/A/Sources/A/x.swift:3:1: warning: unused variable",
        ])
        self.assertEqual(
            project_warnings(log, ROOT),
            [
                "/repo/Packages/A/Sources/A/x.swift:3:1: warning: unused variable",
                "/repo/bukku/App/WindowOpener.swift:65:19: warning: call to main actor-isolated method",
            ],
        )

    def test_ignores_dependencies_notes_and_other_lines(self):
        log = "\n".join([
            "/repo/build.noindex/dd/SourcePackages/checkouts/Dep/y.swift:1:1: warning: deprecated",
            "/repo/Packages/A/.build/checkouts/Dep/z.swift:1:1: warning: deprecated",
            "/elsewhere/Sdk.h:1:1: warning: from the SDK",
            "/repo/bukku/App/A.swift:1:1: note: declared here",
            "ld: warning: duplicate libraries",
            "** BUILD SUCCEEDED **",
        ])
        self.assertEqual(project_warnings(log, ROOT), [])


if __name__ == "__main__":
    unittest.main()
