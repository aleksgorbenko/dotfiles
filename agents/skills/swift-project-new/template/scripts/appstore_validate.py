#!/usr/bin/env python3
import json
import shutil
import subprocess
import sys
import textwrap

LABEL_WIDTH = 8
INDENT = "  "
MAX_WIDTH = 100


def _label(step: dict) -> str:
    if step.get("blocking"):
        return "BLOCKING"
    return {"info": "note"}.get(step["severity"], step["severity"])


def _counted(count: int, noun: str) -> str:
    return f"{count} {noun}" if count == 1 else f"{count} {noun}s"


def _summary(summary: dict) -> str:
    blocking = summary.get("blocking", 0)
    parts = [f"{blocking} blocking"] if blocking else []
    other_errors = summary.get("errors", 0) - blocking
    if other_errors > 0:
        parts.append(_counted(other_errors, "error"))
    if summary.get("warnings", 0):
        parts.append(_counted(summary["warnings"], "warning"))
    if summary.get("infos", 0):
        parts.append(_counted(summary["infos"], "note"))
    return ", ".join(parts)


def validate_lines(report: dict, width: int) -> list[str]:
    lines = [f"App Store submission check: {report['versionString']}"]
    steps = report.get("remediation", {}).get("steps", [])
    if not steps:
        return [*lines, f"{INDENT}ready to submit"]

    lines.append(f"{INDENT}{_summary(report.get('summary', {}))}")
    column = " " * (len(INDENT) + LABEL_WIDTH + 2)
    for step in steps:
        lines.append("")
        lines += textwrap.wrap(
            step["message"],
            width=width,
            initial_indent=f"{INDENT}{_label(step).ljust(LABEL_WIDTH)}  ",
            subsequent_indent=column,
        )
        if step.get("remediation"):
            lines += textwrap.wrap(
                f"fix: {step['remediation']}",
                width=width,
                initial_indent=column,
                subsequent_indent=column + "     ",
            )
    return lines


def main() -> int:
    app_id, version = sys.argv[1], sys.argv[2]
    result = subprocess.run(
        ["asc", "validate", "--app", app_id, "--version", version, "--platform", "MAC_OS", "--output", "json"],
        capture_output=True,
        text=True,
        check=False,
    )
    try:
        report = json.loads(result.stdout)
    except json.JSONDecodeError:
        sys.stderr.write(result.stderr)
        return result.returncode or 1
    width = min(shutil.get_terminal_size((MAX_WIDTH, 24)).columns, MAX_WIDTH)
    sys.stdout.write("\n".join(validate_lines(report, width)) + "\n")
    return 1 if report.get("summary", {}).get("blocking", 0) else 0


if __name__ == "__main__":
    sys.exit(main())
