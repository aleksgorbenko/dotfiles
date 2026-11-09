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
        data = report(
            [entry("Packages/A/Sources/A/x.swift", 2, 10)],
            [entry("Packages/A/Sources/A/x.swift", 7, 10)],
        )
        self.assertEqual(source_coverage(data, ROOT), (7, 10))

    def test_ignores_tests_dependencies_and_files_outside_the_repo(self):
        data = report([
            entry("Packages/A/Sources/A/x.swift", 5, 10),
            entry("Packages/A/Tests/ATests/xTests.swift", 0, 50),
            entry("__APP__UITests/UITests.swift", 0, 40),
            entry("Packages/A/.build/checkouts/Dep/y.swift", 0, 30),
            entry("build.noindex/ci-dd/SourcePackages/checkouts/Dep/z.swift", 0, 30),
            {"path": "/elsewhere/z.swift", "coveredLines": 0, "executableLines": 20},
        ])
        self.assertEqual(source_coverage(data, ROOT), (5, 10))

    def test_ignores_swiftui_view_files(self):
        data = report([
            entry("Packages/A/Sources/A/Model.swift", 5, 10),
            entry("Packages/A/Sources/A/Views/Row.swift", 0, 30),
            entry("Packages/A/Sources/A/AboutWindowView.swift", 0, 40),
            entry("Packages/D/Sources/D/KeycapView.swift", 0, 20),
        ])
        self.assertEqual(source_coverage(data, ROOT), (5, 10))

    def test_sums_across_files(self):
        data = report([
            entry("__APP__/App/a.swift", 1, 4),
            entry("Packages/B/Sources/B/b.swift", 3, 6),
        ])
        self.assertEqual(source_coverage(data, ROOT), (4, 10))


if __name__ == "__main__":
    unittest.main()
