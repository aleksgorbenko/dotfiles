#!/usr/bin/env python3
import json
import pathlib
import re
import sys
import uuid


def target_ids(pbxproj):
    pattern = re.compile(r"(\w{24}) /\* ([^*]+?) \*/ = \{\s*isa = PBXNativeTarget;")
    return {name: identifier for identifier, name in pattern.findall(pbxproj)}


def plan(app, ids, demo_variable, targets):
    container = f"container:{app}.xcodeproj"
    entries = []
    for name, extra in targets:
        entry = {"target": {"containerPath": container, "identifier": ids[name], "name": name}}
        entry.update(extra)
        entries.append(entry)
    return {
        "configurations": [{"id": str(uuid.uuid4()).upper(), "name": "Test Scheme Action", "options": {}}],
        "defaultOptions": {
            "environmentVariableEntries": [{"key": demo_variable, "value": "1"}],
            "performanceAntipatternCheckerEnabled": True,
            "targetForVariableExpansion": {"containerPath": container, "identifier": ids[app], "name": app},
        },
        "testTargets": entries,
        "version": 1,
    }


def main(directory, app, demo_variable):
    root = pathlib.Path(directory)
    ids = target_ids((root / f"{app}.xcodeproj" / "project.pbxproj").read_text())
    unit, ui = f"{app}Tests", f"{app}UITests"
    plans = {
        f"{app}.xctestplan": [(unit, {"parallelizable": True, "skippedTags": {"tags": ["keychain"]}})],
        f"{app}-Unit.xctestplan": [(unit, {"parallelizable": True, "skippedTags": {"tags": ["integration", "keychain"]}})],
        f"{app}-UI.xctestplan": [(ui, {"parallelizable": False})],
        f"{app}-Keychain.xctestplan": [(unit, {"selectedTags": {"tags": ["keychain"]}})],
    }
    for name, targets in plans.items():
        text = json.dumps(plan(app, ids, demo_variable, targets), indent=2, separators=(",", " : "))
        (root / name).write_text(text + "\n")


if __name__ == "__main__":
    main(*sys.argv[1:4])
