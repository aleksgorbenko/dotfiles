#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
import tempfile


def _fill(value, tokens):
    if isinstance(value, str):
        for token, replacement in tokens.items():
            value = value.replace(token, replacement)
        return value
    if isinstance(value, list):
        return [_fill(item, tokens) for item in value]
    if isinstance(value, dict):
        return {key: _fill(item, tokens) for key, item in value.items()}
    return value


def render(config, app, container):
    return _fill(config["workflows"], {"{app}": app, "{container}": container})


def _link(resource_type, resource_id):
    return {"data": {"type": resource_type, "id": resource_id}}


def create_payload(attributes, product, repository, xcode, macos):
    return {"data": {
        "type": "ciWorkflows",
        "attributes": attributes,
        "relationships": {
            "product": _link("ciProducts", product),
            "repository": _link("scmRepositories", repository),
            "xcodeVersion": _link("ciXcodeVersions", xcode),
            "macOsVersion": _link("ciMacOsVersions", macos),
        },
    }}


def update_payload(workflow_id, attributes, xcode, macos):
    return {"data": {
        "type": "ciWorkflows",
        "id": workflow_id,
        "attributes": attributes,
        "relationships": {
            "xcodeVersion": _link("ciXcodeVersions", xcode),
            "macOsVersion": _link("ciMacOsVersions", macos),
        },
    }}


def version_id(versions, name):
    for version in versions["data"]:
        if version["attributes"]["name"] == name:
            return version["id"]
    sys.exit(f"error: no Xcode Cloud version named {name}")


def existing_ids(listed):
    return {workflow["attributes"]["name"]: workflow["id"] for workflow in listed["data"]}


def _asc(*arguments):
    result = subprocess.run(["asc", *arguments, "--output", "json"], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        sys.exit(f"error: asc {' '.join(arguments)} failed:\n{result.stderr.strip()}")
    return json.loads(result.stdout)


def _send(command, payload, *arguments):
    with tempfile.NamedTemporaryFile("w", suffix=".json") as file:
        json.dump(payload, file)
        file.flush()
        _asc("xcode-cloud", "workflows", command, "--file", file.name, *arguments)


def setup(app_id, app, container, config_path, dry_run):
    products = _asc("xcode-cloud", "products", "list", "--app", app_id)["data"]
    if not products:
        sys.exit(f"error: no Xcode Cloud product for {app}: open the project in Xcode and create the first workflow")
    product = products[0]["id"]
    repositories = _asc("xcode-cloud", "products", "primary-repositories", "--id", product)["data"]
    if not repositories:
        sys.exit(f"error: the Xcode Cloud product for {app} has no repository")
    xcode_versions = _asc("xcode-cloud", "xcode-versions", "list")
    macos_versions = _asc("xcode-cloud", "macos-versions", "list")
    existing = existing_ids(_asc("xcode-cloud", "workflows", "list", "--app", app_id))
    config = json.load(open(config_path, encoding="utf-8"))
    for workflow in render(config, app, container):
        attributes = workflow["attributes"]
        xcode = version_id(xcode_versions, workflow["xcodeVersion"])
        macos = version_id(macos_versions, workflow["macOsVersion"])
        name = attributes["name"]
        if name in existing:
            payload = update_payload(existing[name], attributes, xcode, macos)
            print(f"== Xcode Cloud workflow {name}: update")
            if dry_run:
                print(json.dumps(payload, indent=2))
            else:
                _send("update", payload, "--id", existing[name])
        else:
            payload = create_payload(attributes, product, repositories[0]["id"], xcode, macos)
            print(f"== Xcode Cloud workflow {name}: create")
            if dry_run:
                print(json.dumps(payload, indent=2))
            else:
                _send("create", payload)


def main():
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    setup_parser = commands.add_parser("setup")
    setup_parser.add_argument("--app-id", required=True)
    setup_parser.add_argument("--app", required=True)
    setup_parser.add_argument("--container", required=True)
    setup_parser.add_argument("--config", required=True)
    setup_parser.add_argument("--dry-run", action="store_true")
    arguments = parser.parse_args()
    setup(arguments.app_id, arguments.app, arguments.container, arguments.config, arguments.dry_run)


if __name__ == "__main__":
    main()
