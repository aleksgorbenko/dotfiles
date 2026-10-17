#!/usr/bin/env python3
import pathlib
import plistlib
import subprocess
import sys

ADDED_BY_SIGNING = {"com.apple.application-identifier", "com.apple.developer.team-identifier"}


def entitlement_differences(expected, actual):
    actual = {key: value for key, value in actual.items() if key not in ADDED_BY_SIGNING}
    added = [f"added: {key}" for key in sorted(actual.keys() - expected.keys())]
    removed = [f"removed: {key}" for key in sorted(expected.keys() - actual.keys())]
    changed = [f"changed: {key}" for key in sorted(expected.keys() & actual.keys()) if expected[key] != actual[key]]
    return added + removed + changed


def signed_entitlements(app_path):
    output = subprocess.run(
        ["codesign", "-d", "--entitlements", "-", "--xml", app_path], capture_output=True, check=True
    ).stdout
    return plistlib.loads(output) if output.strip() else {}


def main():
    app_path, entitlements_path = sys.argv[1], sys.argv[2]
    expected = plistlib.loads(pathlib.Path(entitlements_path).read_bytes())
    differences = entitlement_differences(expected, signed_entitlements(app_path))
    for difference in differences:
        print(f"{app_path}: {difference}")
    if differences:
        sys.exit(1)
    print(f"{app_path}: entitlements match {entitlements_path}")


if __name__ == "__main__":
    main()
