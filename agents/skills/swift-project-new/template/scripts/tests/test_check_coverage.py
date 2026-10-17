import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_coverage import source_coverage

ROOT = "/repo/"


def report(*targets):
    return {"targets": [{"files": list(files)} for files in targets]}


def entry(path, covered, executable):
    return {"path": ROOT + path, "coveredLines": covered, "executableLines": executable}


class SourceCoverageTests(unittest.TestCase):
    def test_merges_a_file_compiled_into_several_bundles_by_its_best_count(self):
        data = report([entry("Packages/A/Sources/A/x.swift", 2, 10)], [entry("Packages/A/Sources/A/x.swift", 7, 10)])
        self.assertEqual(source_coverage(data, ROOT), (7, 10))

    def test_ignores_tests_views_dependencies_and_outside_files(self):
        data = report([
            entry("app/Model.swift", 5, 10),
            entry("appTests/ModelTests.swift", 0, 50),
            entry("appUITests/UITests.swift", 0, 40),
            entry("Packages/A/Tests/ATests/xTests.swift", 0, 30),
            entry("Packages/A/.build/checkouts/Dep/y.swift", 0, 30),
            entry("build.noindex/dd/SourcePackages/checkouts/Dep/z.swift", 0, 30),
            entry("app/Views/Row.swift", 0, 30),
            entry("app/SettingsView.swift", 0, 30),
            entry("app/MyAppApp.swift", 0, 12),
            {"path": "/elsewhere/z.swift", "coveredLines": 0, "executableLines": 20},
        ])
        self.assertEqual(source_coverage(data, ROOT), (5, 10))


    def test_new_project_with_nothing_to_measure_passes(self):
        from check_coverage import coverage_percent
        self.assertEqual(coverage_percent(0, 0), 100.0)


if __name__ == "__main__":
    unittest.main()
