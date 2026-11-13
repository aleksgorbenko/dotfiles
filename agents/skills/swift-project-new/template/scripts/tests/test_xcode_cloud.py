import importlib.util
import json
import pathlib
import re
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
SPEC = importlib.util.spec_from_file_location("xcode_cloud", ROOT / "scripts" / "xcode_cloud.py")
xcode_cloud = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(xcode_cloud)

CONFIG = json.loads((ROOT / "appstore" / "xcode-cloud.json").read_text())


class XcodeCloudTests(unittest.TestCase):
    def test_tokens_take_the_app_and_container(self):
        workflow = xcode_cloud.render(CONFIG, "Sample", "Sample.xcworkspace")[0]

        attributes = workflow["attributes"]
        self.assertEqual(attributes["name"], "Default")
        self.assertEqual(attributes["containerFilePath"], "Sample.xcworkspace")
        self.assertEqual(attributes["actions"][0]["name"], "Sample - macOS")
        self.assertEqual(attributes["actions"][0]["scheme"], "Sample")
        self.assertEqual(attributes["actions"][0]["testConfiguration"]["testPlanName"], "Sample")
        self.assertNotIn("{app}", json.dumps(workflow))

    def test_config_names_the_app_only_through_tokens(self):
        text = (ROOT / "appstore" / "xcode-cloud.json").read_text()
        attributes = CONFIG["workflows"][0]["attributes"]

        self.assertEqual(set(re.findall(r"\{[a-z]+\}", text)), {"{app}", "{container}"})
        self.assertEqual(attributes["containerFilePath"], "{container}")
        self.assertEqual(attributes["actions"][0]["scheme"], "{app}")
        self.assertEqual(attributes["actions"][0]["testConfiguration"]["testPlanName"], "{app}")

    def test_create_payload_links_product_repository_and_versions(self):
        workflow = xcode_cloud.render(CONFIG, "Sample", "Sample.xcworkspace")[0]

        payload = xcode_cloud.create_payload(workflow["attributes"], "product-1", "repo-1", "xcode-1", "macos-1")

        self.assertEqual(payload["data"]["type"], "ciWorkflows")
        self.assertEqual(payload["data"]["attributes"]["name"], "Default")
        self.assertEqual(
            {name: link["data"] for name, link in payload["data"]["relationships"].items()},
            {
                "product": {"type": "ciProducts", "id": "product-1"},
                "repository": {"type": "scmRepositories", "id": "repo-1"},
                "xcodeVersion": {"type": "ciXcodeVersions", "id": "xcode-1"},
                "macOsVersion": {"type": "ciMacOsVersions", "id": "macos-1"},
            },
        )

    def test_update_payload_names_the_workflow_and_its_versions(self):
        workflow = xcode_cloud.render(CONFIG, "Sample", "Sample.xcworkspace")[0]

        payload = xcode_cloud.update_payload("workflow-1", workflow["attributes"], "xcode-1", "macos-1")

        self.assertEqual(payload["data"]["id"], "workflow-1")
        self.assertEqual(payload["data"]["type"], "ciWorkflows")
        self.assertEqual(payload["data"]["attributes"]["clean"], True)
        self.assertEqual(payload["data"]["relationships"]["xcodeVersion"]["data"]["id"], "xcode-1")
        self.assertNotIn("product", payload["data"]["relationships"])

    def test_version_id_is_found_by_name(self):
        versions = {"data": [
            {"id": "a", "attributes": {"name": "Xcode 27.2"}},
            {"id": "b", "attributes": {"name": "Latest Release"}},
        ]}

        self.assertEqual(xcode_cloud.version_id(versions, "Latest Release"), "b")
        with self.assertRaisesRegex(SystemExit, "no Xcode Cloud version named Xcode 99"):
            xcode_cloud.version_id(versions, "Xcode 99")

    def test_existing_workflows_are_matched_by_name(self):
        listed = {"data": [{"id": "w1", "attributes": {"name": "Default"}}]}

        self.assertEqual(xcode_cloud.existing_ids(listed), {"Default": "w1"})


if __name__ == "__main__":
    unittest.main()
