#!/usr/bin/env python3
import json
import pathlib
import sys

EXCLUDED_PARTS = ("Tests/", "/.build/", "DerivedData", "/SourcePackages/", "/Views/", "DesignSystem/")
EXCLUDED_SUFFIXES = ("View.swift", "App.swift")


def source_coverage(report, root):
    best = {}
    for target in report["targets"]:
        for source in target["files"]:
            path = source["path"]
            if not path.startswith(root):
                continue
            relative = path[len(root):]
            if relative.endswith(EXCLUDED_SUFFIXES) or any(part in relative for part in EXCLUDED_PARTS):
                continue
            covered = best.get(relative, (0, source["executableLines"]))[0]
            best[relative] = (max(covered, source["coveredLines"]), source["executableLines"])
    return sum(c for c, _ in best.values()), sum(e for _, e in best.values())


def coverage_percent(covered, executable):
    return 100 * covered / executable if executable else 100.0


def main():
    report_path, minimum = sys.argv[1], float(sys.argv[2])
    root = str(pathlib.Path(__file__).resolve().parent.parent) + "/"
    covered, executable = source_coverage(json.loads(pathlib.Path(report_path).read_text()), root)
    percent = coverage_percent(covered, executable)
    print(f"Line coverage {percent:.1f}% ({covered}/{executable} lines), minimum {minimum:.1f}%")
    if percent < minimum:
        sys.exit(1)


if __name__ == "__main__":
    main()
