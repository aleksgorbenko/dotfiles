#!/usr/bin/env python3
import json
import pathlib
import re
import sys

PLAN = "__APP__.xctestplan"
UNIT_PLAN = "__APP__-Unit.xctestplan"
INTEGRATION_TAG = "integration"
KEYCHAIN_TAG = "keychain"
APP_TEST_TARGET = "__APP__Tests"
WORKSPACE = "__APP__.xcworkspace"


def package_test_targets(root):
    targets = {}
    for manifest in sorted((root / "Packages").glob("*/Package.swift")):
        names = re.findall(r'\.testTarget\(\s*name:\s*"([^"]+)"', manifest.read_text())
        targets[f"Packages/{manifest.parent.name}"] = set(names)
    return targets


def workspace_packages(root):
    contents = (root / WORKSPACE / "contents.xcworkspacedata").read_text()
    return set(re.findall(r'location = "group:(Packages/[^"]+)"', contents))


def plan_entries(root):
    plan = json.loads((root / PLAN).read_text())
    entries = set()
    for test_target in plan["testTargets"]:
        target = test_target["target"]
        container = target["containerPath"].removeprefix("container:").replace("\\/", "/")
        if container.startswith("Packages/"):
            entries.add((container, target["name"]))
    return entries


def plan_targets(root, plan):
    return json.loads((root / plan).read_text())["testTargets"]


def unit_plan_problems(root):
    names = [test_target["target"]["name"] for test_target in plan_targets(root, PLAN)]
    unit_targets = plan_targets(root, UNIT_PLAN)
    unit_names = [test_target["target"]["name"] for test_target in unit_targets]
    problems = [f"{name} is missing from {UNIT_PLAN}" for name in names if name not in unit_names]
    for test_target in unit_targets:
        name = test_target["target"]["name"]
        if name not in names:
            problems.append(f"{name} in {UNIT_PLAN} is not in {PLAN}")
        elif INTEGRATION_TAG not in test_target.get("skippedTags", {}).get("tags", []):
            problems.append(f"{name} in {UNIT_PLAN} does not skip the {INTEGRATION_TAG} tag")
    return problems


def keychain_problems(root):
    for test_target in plan_targets(root, PLAN):
        if test_target["target"]["name"] == APP_TEST_TARGET:
            if KEYCHAIN_TAG in test_target.get("skippedTags", {}).get("tags", []):
                return []
            return [f"{APP_TEST_TARGET} in {PLAN} does not skip the {KEYCHAIN_TAG} tag"]
    return [f"{APP_TEST_TARGET} is missing from {PLAN}"]


def find_problems(root):
    targets = package_test_targets(root)
    in_workspace = workspace_packages(root)
    in_plan = plan_entries(root)
    problems = []
    for package, names in targets.items():
        if names and package not in in_workspace:
            problems.append(f"{package} has test targets but is missing from {WORKSPACE}")
        for name in sorted(names):
            if (package, name) not in in_plan:
                problems.append(f"{name} ({package}) is missing from {PLAN}")
    for package, name in sorted(in_plan):
        if name not in targets.get(package, set()):
            problems.append(f"{name} in {PLAN} has no matching test target in {package}")
    return problems + unit_plan_problems(root) + keychain_problems(root)


def main():
    root = pathlib.Path(__file__).resolve().parent.parent
    problems = find_problems(root)
    for problem in problems:
        print(problem, file=sys.stderr)
    if problems:
        sys.exit(1)
    print(f"{PLAN} covers every package test target, {UNIT_PLAN} skips the {INTEGRATION_TAG} tag")


if __name__ == "__main__":
    main()
