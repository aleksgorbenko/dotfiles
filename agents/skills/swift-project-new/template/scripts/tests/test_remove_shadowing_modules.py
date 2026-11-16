import pathlib
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parent.parent / "remove-shadowing-modules.sh"


class RemoveShadowingModulesTests(unittest.TestCase):
    def setUp(self):
        self.temporary_directory = tempfile.TemporaryDirectory()
        self.derived_data = pathlib.Path(self.temporary_directory.name) / "DerivedData"
        self.products = self.derived_data / "Build" / "Products" / "Debug"
        (self.products / "PackageFrameworks" / "Models.framework").mkdir(parents=True)

    def tearDown(self):
        self.temporary_directory.cleanup()

    def run_script(self, *derived_data):
        return subprocess.run(
            [str(SCRIPT), *map(str, derived_data)],
            capture_output=True,
            text=True,
            check=True,
        )

    def test_removes_a_module_that_shadows_a_package_framework(self):
        (self.products / "Models.swiftmodule").mkdir()

        self.run_script(self.derived_data)

        self.assertFalse((self.products / "Models.swiftmodule").exists())
        self.assertTrue((self.products / "PackageFrameworks" / "Models.framework").exists())

    def test_keeps_a_module_without_a_package_framework(self):
        (self.products / "App.swiftmodule").mkdir()

        self.run_script(self.derived_data)

        self.assertTrue((self.products / "App.swiftmodule").exists())

    def test_ignores_a_missing_derived_data_folder(self):
        result = self.run_script(self.derived_data.parent / "missing")

        self.assertEqual(result.stdout, "")


if __name__ == "__main__":
    unittest.main()
