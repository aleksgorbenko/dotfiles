import json
import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent.parent))

from check_test_plan import find_problems


def write_package(root, name, test_targets):
    package_dir = root / "Packages" / name
    package_dir.mkdir(parents=True)
    targets = "\n".join(f'        .testTarget(\n            name: "{t}",\n            dependencies: []\n        ),' for t in test_targets)
    (package_dir / "Package.swift").write_text(f'let package = Package(\n    name: "{name}",\n    targets: [\n{targets}\n    ]\n)\n')


def write_workspace(root, packages):
    refs = "\n".join(f'   <FileRef\n      location = "group:Packages/{p}">\n   </FileRef>' for p in packages)
    workspace = root / "__APP__.xcworkspace"
    workspace.mkdir()
    (workspace / "contents.xcworkspacedata").write_text(f'<Workspace version = "1.0">\n{refs}\n</Workspace>\n')


def plan_targets(entries):
    targets = [
        {"target": {"containerPath": f"container:Packages/{package}", "identifier": name, "name": name}}
        for package, name in entries
    ]
    targets.append({"target": {"containerPath": "container:__APP__.xcodeproj", "identifier": "ABC", "name": "__APP__Tests"}})
    return targets


def write_unit_plan(root, entries, skipped_tags=("integration",)):
    targets = [dict(target, skippedTags={"tags": list(skipped_tags)}) for target in plan_targets(entries)]
    (root / "__APP__-Unit.xctestplan").write_text(json.dumps({"testTargets": targets}))


def write_plan(root, entries, app_skipped_tags=("keychain",)):
    targets = plan_targets(entries)
    targets[-1]["skippedTags"] = {"tags": list(app_skipped_tags)}
    (root / "__APP__.xctestplan").write_text(json.dumps({"testTargets": targets}))
    write_unit_plan(root, entries)


class FindProblemsTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.root = pathlib.Path(self.temporary_directory.name)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def test_in_sync_reports_nothing(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_package(self.root, "Empty", [])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"]])

        self.assertEqual(find_problems(self.root), [])

    def test_app_tests_running_keychain_tests_in_the_default_plan_is_a_problem(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"]], app_skipped_tags=())

        self.assertEqual(find_problems(self.root), ["__APP__Tests in __APP__.xctestplan does not skip the keychain tag"])

    def test_reports_test_target_missing_from_plan(self):
        write_package(self.root, "Alpha", ["AlphaTests", "BetaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"]])

        self.assertEqual(find_problems(self.root), ["BetaTests (Packages/Alpha) is missing from __APP__.xctestplan"])

    def test_reports_package_with_tests_missing_from_workspace(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_workspace(self.root, [])
        write_plan(self.root, [["Alpha", "AlphaTests"]])

        self.assertEqual(find_problems(self.root), ["Packages/Alpha has test targets but is missing from __APP__.xcworkspace"])

    def test_reports_stale_plan_entry(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"], ["Alpha", "GoneTests"]])

        self.assertEqual(find_problems(self.root), ["GoneTests in __APP__.xctestplan has no matching test target in Packages/Alpha"])

    def test_reports_target_missing_from_unit_plan(self):
        write_package(self.root, "Alpha", ["AlphaTests", "BetaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"], ["Alpha", "BetaTests"]])
        write_unit_plan(self.root, [["Alpha", "AlphaTests"]])

        self.assertEqual(find_problems(self.root), ["BetaTests is missing from __APP__-Unit.xctestplan"])

    def test_reports_unit_plan_target_not_in_plan(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"]])
        write_unit_plan(self.root, [["Alpha", "AlphaTests"], ["Alpha", "GoneTests"]])

        self.assertEqual(find_problems(self.root), ["GoneTests in __APP__-Unit.xctestplan is not in __APP__.xctestplan"])

    def test_reports_unit_plan_target_that_runs_integration_tests(self):
        write_package(self.root, "Alpha", ["AlphaTests"])
        write_workspace(self.root, ["Alpha"])
        write_plan(self.root, [["Alpha", "AlphaTests"]])
        write_unit_plan(self.root, [["Alpha", "AlphaTests"]], skipped_tags=())

        self.assertEqual(
            find_problems(self.root),
            [
                "AlphaTests in __APP__-Unit.xctestplan does not skip the integration tag",
                "__APP__Tests in __APP__-Unit.xctestplan does not skip the integration tag",
            ],
        )


if __name__ == "__main__":
    unittest.main()
